module SuperStacker
  class ParametersDSL
    attr_reader :template, :document
    
    def initialize(template)
      @template = template
      @document = {}

      compile
    end

    def compile
      instance_eval(@template, 'parameters.rb', 0)
    end

    def derive(parameter, from: nil, &block)
      @document[:derived] ||= {}
      @document[:derived][parameter] = {from: from, block: block}
    end
  end
end
