require 'json'

module SuperStacker
  module Stack

    module_function

    def resolve_stack(url)
      case url
      when /cfm:\/\/(.*)/
        stack_from_cfm($1)
      else
        stack_from_dir(url)
      end
    end

    def stack_from_cfm(name)
      cfm = AWS::CloudFormation.new
      stack = cfm.stacks[name]

      params = JSON.pretty_generate(sort_hash(stack.parameters))
      {template: stack.template, params: params}
    end

    def stack_from_dir(path)
      path = File.expand_path(path)
      template_file = File.join(path, 'template.rb')
      template_body = File.read(template_file)

      template = ::SuperStacker::Template::Template.new(template_body)

      params_file = File.join(path, 'params.json')
      if File.exists? params_file
        cfm_format_params = JSON.load(File.read(params_file))
        unsorted_params = from_cfm_format(cfm_format_params)
        params = JSON.pretty_generate(sort_hash(unsorted_params))
      else
        params = nil
      end

      # add newline to end of output to match cfm format
      {template: JSON.pretty_generate(template.compile) + "\n", params: params}
    end

    def sort_hash(hash)
      Hash[*(hash.sort.flatten)]
    end

    def from_cfm_format(params)
      output = {}
      params.each { |p| output[p['parameter_key']] = p['parameter_value'] }
      output
    end

  end
end
