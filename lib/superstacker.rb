require "superstacker/primitives"
require "superstacker/fn"
require "pp"

module SuperStacker
  class Stack

    def initialize(dir)
      @dir = dir
      @root = {}
    end

    def compile
      spec = File.open(specfile, "r") { |io| io.read }
      instance_eval(spec, specfile, 0)
      @root
    end

    def description(desc)
      @root["Description"] = desc
    end

    def resource(name, type, &block)
      res = Resource.new(name, type, &block)

      @root["Resources"] ||= {}
      @root["Resources"][res.name] = res
    end

    def mapping(name, &block)
      map = Mapping.new(name, &block)

      @root["Mappings"] ||= {}
      @root["Mappings"][map.name] = map
    end

    def parameter(name, opts = {})
      raise "Type parameter is required!" unless opts.include? "Type"

      @root["Parameters"] ||= {}
      @root["Parameters"][name] = opts
    end

    def output(name, value, description = nil)
      output = { "Value" => value }
      output["Description"] = description unless description.nil?

      @root["Outputs"] ||= {}
      @root["Outputs"][name] = output
    end

    def specfile
      File.join(File.expand_path(@dir), 'spec.rb')
    end
  end
end
