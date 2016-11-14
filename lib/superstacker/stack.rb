require 'aws-sdk-v1'
require 'json'
require 'superstacker/template_dsl'
require 'superstacker/parameters_dsl'
require 'pp'

module SuperStacker
  class StackCollection
    # TODO: we could implement comparable here, and use this to
    # generate the build order?! collection.sort.each do |build_me|
    # this is both a good and a fun idea. We need to implement <=>
    # to do this.

    # TODO:
    # methods which return collections on this fucker return an array,
    # rather than a StackCollection. Can we fix this?
    include Enumerable
    
    def initialize(stacks)
      @stacks = stacks
    end

    def each(&block)
      @stacks.each do |stack|
        if block_given?
          block.call(stack)
        else
          yield stack
        end
      end
    end

    def <<(stack)
      @stacks << stack
    end

    def concat(stacks)
      @stacks.concat(stacks)
    end

    def with_output(output)
      result = self.select do |s| 
        begin
          s.entity.template['Outputs'].include? output
        rescue NoMethodError
          false
        end
      end

      if result.count > 1
        raise "Found an unexpected number of stacks: #{result.count}"
      end

      return result.count.zero? ? nil : result[0]
    end

    def with_parameter(parameter)
      self.select do |s| 
        begin
          s.entity.template['Parameters'].include? parameter
        rescue NoMethodError
          false
        end
      end
    end

    def outputs
      self.map { |s| s.entity.outputs.keys }.flatten.uniq
    end

    def duplicate_outputs
      raw_outputs = self.map { |s| s.entity.outputs.keys }.flatten
      raw_outputs.select { |o| raw_outputs.count(o) > 1 }.uniq
    end

    def parameters
      self.map { |s| s.entity.parameters.keys }.flatten.uniq
    end

    def parameters_set?
      self.map { |s| s.entity.parameters.map { |k,v| ! v.nil? } }.flatten.all?
    end

    def derived_parameters
      self.map { |s| s.derived.keys }.flatten.uniq
    end

    def required_parameters
      self.parameters - ( self.outputs + self.derived_parameters )
    end
  end
  
  StackEntity = Struct.new(:template, :parameters, :outputs) do
    def self.from_aws(stack_name)
      # TODO: globalize?
      cfm = AWS::CloudFormation.new

      cfm_stack = cfm.stacks[stack_name]

      entity = new
      entity.template = JSON.load(cfm_stack.template)
      entity.outputs = Hash[cfm_stack.outputs.map { |o| [o.key, o.value] }]
      entity.parameters = cfm_stack.parameters

      entity
    end

    def self.from_dir(dir)
      entity = new
      template_dsl = File.read(File.join(dir, 'template.rb'))
      entity.template = TemplateDSL.new(template_dsl).compile
      
      if entity.template.has_key? 'Parameters'
        entity.parameters = Hash[entity.template['Parameters'].keys.map { |k| [k,nil] }]
      else
        entity.parameters = {}
      end

      if entity.template.has_key? 'Outputs'
        entity.outputs = Hash[entity.template['Outputs'].keys.map { |k| [k,nil] }]
      else
        entity.outputs = {}
      end
      
      entity
    end

    def set_parameter(k,v)
      if template['Parameters'].keys.include? k
        parameters ||= {}
        parameters[k] = v
      else
        raise "Unknown parameter: #{k}"
      end
    end

    def set_output(k,v)
      if template['Outputs'].keys.include? k
        outputs ||= {}
        outputs[k] = v
      else
        raise "Unknorn output: #{k}"
      end
    end

    def parameters_set?
      template['Parameters'].keys.sort == parameters.keys.sort
    end

    def outputs_set?
      template['Outputs'].keys.sort == outputs.keys.sort
    end
  end

  class Stack
    attr_reader :dir, :name, :prefix, :entity, :derived
 
   def self.from_aws(name)
      entity = StackEntity.from_aws(name)

      new(name, entity)
   end

   def self.from_dir(dir, prefix=nil)
     entity = StackEntity.from_dir(dir)
     dirname = File.basename(dir)
     name = prefix.nil? ? dirname : prefix+dirname

     parameters_file = File.join(dir, 'parameters.rb')
     if File.exists?(parameters_file)
       params_file = File.read(File.join(dir, 'parameters.rb'))
       derived = ParametersDSL.new(params_file).document[:derived]
     else
       derived = {}
     end
     
     new(name, entity, derived: derived)
   end

   def initialize(name, entity, derived: {})
     @name = name
     @entity = entity
     @derived = derived
   end

   def inspect
     name
   end
 end
end
