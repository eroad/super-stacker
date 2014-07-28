require 'superstacker'
require 'superstacker/action'
require 'superstacker/dependency'
require 'thor'
require 'diffy'

module SuperStacker

  class Cli < Thor
    desc 'provision NAME STACK [PARAM]...', 'provisions the given stack'
    option :parents, type: :array, default: []
    def provision(name, stack, *params)
      stack = stack_from_url(stack)
      parents = fetch_stacks(options[:parents])

      known_params = fetch_params(StackCollection.new([stack]), params, parents)
      load_params(stack, known_params, parents)

      status = SuperStacker::Action.provision(name, stack)

      monitor_status(status)
    end

    desc 'update NAME PATH [PARAM]...', 'update stack at NAME with stack at PATH'
    def update(name, path, *params)
      stack = Stack.from_dir(path)
      parents = StackCollection.new([Stack.from_aws(name)])

      known_params = fetch_params(StackCollection.new([stack]), params, parents)
      load_params(stack, known_params, parents)
      
      status = SuperStacker::Action.update(name, stack)

      monitor_status(status)
    end

    desc 'compare A B', 'compares stack A with stack B'
    option :'a-params-file'
    option :'b-params-file'
    option :context, type: :numeric, default: 10
    def compare(a, b)
      sa = stack_from_url(a).entity
      if options['a-params-file']
        params = File.read(File.expand_path(options['a-params-file']))
        sa.parameters = JSON.load(params)
      end

      sb = stack_from_url(b).entity
      if options['b-params-file']
        params = File.read(File.expand_path(options['b-params-file']))
        sb.parameters = JSON.load(params)
      end

      puts '-' * 35 + ' TEMPLATE ' + '-' * 35
      puts Diffy::Diff.new(JSON.pretty_generate(sa.template)+"\n",
                           JSON.pretty_generate(sb.template)+"\n",
                           :context => options[:context]).to_s(:color)

      puts '-' * 34 + ' PARAMETERS ' + '-' * 34
      puts Diffy::Diff.new(JSON.pretty_generate(sa.parameters)+"\n",
                           JSON.pretty_generate(sb.parameters)+"\n",
                           :context => options[:context]).to_s(:color)
    end

    desc 'template STACK', 'retrieves or generates the JSON template for the given stack'
    def template(stack)
      stack = stack_from_url(stack)
      puts JSON.pretty_generate(stack.entity.template)
    end

    desc 'parameters STACK [PARAM]...', 'retrieves or generates the parameters for the given stack'
    option :parents, type: :array, default: []
    def parameters(stack, *params)
      stack = stack_from_url(stack)
      parents = fetch_stacks(options[:parents])

      known_params = fetch_params(StackCollection.new([stack]), params, parents)
      load_params(stack, known_params, parents)
      
      puts JSON.pretty_generate(stack.entity.parameters)
    end

    desc 'superstack PATH [PARAM]...', 'superstacks (tm) the collection of stacks found at PATH'
    option :exclude, type: :string, desc: 'regex matching the directory name of stacks to exclude'
    option :prefix, type: :string, desc: 'prefix to use in front of stack name'
    def superstack(path, *params)
      path = File.expand_path(path)
      stacks = Dir.glob(File.join(File.expand_path(path), '*'))
      
      if options[:exclude]
        stacks = stacks.reject { |s| File.basename(s) =~ /#{options[:exclude]}/ }
      end

      stacks = stacks.keep_if { |s| File.exists? File.join(s, 'template.rb') }
      stacks = StackCollection.new(stacks.map { |s| Stack.from_dir(s) })

      graph = Dependency::Graph.new(stacks)
      build_order = Dependency::find_build_order(graph)
      known_params = fetch_params(stacks, params)

      parents = StackCollection.new([])
      build_order.each do |stack|
        name = options[:prefix].nil? ? stack.name : options[:prefix]+stack.name
        say "provisioning stack: #{name}"

        load_params(stack, known_params, parents)

        begin
          existing = Stack.from_aws(name)
        rescue AWS::CloudFormation::Errors::ValidationError
          existing = nil
        end
        
        if ! existing.nil?
          action = nil
          while ! (['y', 'n', 's'].include? action)
            action = ask 'Stack already exists, what would you like to do? [y/n/d/s]', :red

            if action == 'd'
              diff_stacks(existing.entity, stack.entity)
            end
          end

          if action == 's'
            parents << existing
            next
          elsif action == 'n'
            exit 1
          end

          status = Action.update(name, stack)
        else
          status = Action.provision(name, stack)
        end

        monitor_status(status)

        if status.failed?
          raise 'TODO: everything is all jacked, sort it out cuzzie.'
        end

        parents << Stack.from_aws(name)
      end

      # TODO: tidy up error display handling for:
      # SuperStacker::FixedKeyHash::UnknownKeys
      # No stack to update/stack doesn't exist
      # No changes to stack error from AWS
    end

    no_tasks do
      def stack_from_url(url)
        case url
        when /cfm:\/\/(.*)/
          Stack.from_aws($1)
        else
          Stack.from_dir(File.expand_path(url))
        end
      end

      def fetch_stacks(stacks)
        stacks = stacks.map { |s| Stack.from_aws(s) }
        StackCollection.new(stacks)
      end

      def monitor_status(status)
        # TODO: might be nice to add a timeout here?
        while (! status.complete?) && (! status.failed?)
          print '.' and $stdout.flush
          status.update!
          sleep 3
        end
        
        puts ''

        if status.complete?
          say 'Stack provisioned successfully! Hooray!', :green
        else
          # TODO: debug output here.
          say 'Stack provisioning failed! =(', :red
        end
      end
      
      def put_table(columns)
        columns = [['parameters:','values:']] + columns
        longest_key = Hash[columns].keys.map { |v| "#{v}".length }.max

        columns.each_with_index do |param, i|
          pad = (longest_key - "#{param[0]}".length) / 8
          say "#{param[0]}" + "\t" * pad + "\t#{param[1]}\n"
        end
      end

      def fetch_params(stacks, params, parents=nil)
        hydrated_params = parse_params(params)
        required_params = stacks.required_parameters

        if ! parents.nil?
          required_params -= (parents.outputs + parents.parameters)
        end

        if hydrated_params.is_a? Hash
          if (hydrated_params.keys & required_params).sort == required_params.sort
            unknown_params = hydrated_params.keys - stacks.parameters
            raise "Unknown parameters found: #{unknown_params}" if unknown_params.any?
            
            hydrated_params
          else
            say 'Not all required parameters were found while merging:', :red
            display_merge_params(required_params, hydrated_params)
            exit 1
          end
        else
          if hydrated_params.count == required_params.count
            Hash[required_params.zip(hydrated_params)]
          elsif stacks.parameters_set?
            # we're probably doing a clone operation or retrieving the
            # parameters of a running stack. no need to ask for params.
            {}
          else
            say 'Input parameter count doesn\'t match required parameter count:', :red
            display_positional_params(required_params, hydrated_params)
            exit 1
          end
        end
      end

      def resolve_parameter(param, known_params, derived, parents)
        if known_params.include? param
          known_params[param]
        elsif derived.include? param
          source = resolve_parameter(derived[param][:from], known_params, derived, parents)
          source.nil? ? nil : derived[param][:block].call(source)
        elsif parents.parameters.include? param
          parent = parents.with_parameter(param).first
          parent.entity.parameters[param]
        elsif parents.outputs.include? param
          parent = parents.with_output(param)
          parent.entity.outputs[param]
        end
      end

      def load_params(stack, known_params, parents)
        stack.entity.parameters.keys.each do |param|
          value = resolve_parameter(param, known_params, stack.derived, parents)

          if ! value.nil?
            stack.entity.parameters[param] = value
          elsif value.nil? and ! stack.entity.parameters[param].nil?
            # do nothing, parameter is already set!
          else
            raise "Unable to figure out how to resolve parameter: #{param}"
          end
        end
      end

      def parse_params(params)
        if not params.empty? and params.map { |p| p.include? '=' }.all?
          Hash[params.map { |p| p.split '=' }]
        else
          params
        end
      end

      def display_positional_params(required_params, known_params)
        if known_params.count > required_params.count
          # pad required params out to match known_params length
          required_params.fill(nil, required_params.length,
                               known_params.length - required_params.length)
        end
        put_table(required_params.zip(known_params))
      end

      def display_merge_params(required_params, known_params)
        keys = (required_params + known_params.keys).uniq
        params = keys.map do |k|
          if known_params.include? k
            [k, known_params[k]]
          else
            [k,nil]
          end
        end
        put_table(params)
      end

      def diff_stacks(sa, sb)
        puts '-' * 35 + ' TEMPLATE ' + '-' * 35
        puts Diffy::Diff.new(JSON.pretty_generate(sa.template)+"\n",
                             JSON.pretty_generate(sb.template)+"\n",
                             :context => options[:context]).to_s(:color)

        puts '-' * 34 + ' PARAMETERS ' + '-' * 34
        puts Diffy::Diff.new(JSON.pretty_generate(Hash[sa.parameters.sort])+"\n",
                             JSON.pretty_generate(Hash[sb.parameters.sort])+"\n",
                             :context => options[:context]).to_s(:color)
      end
    end
  end

end
