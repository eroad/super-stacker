require "superstacker/resource"
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

    def parameter(name, opts = {})
      raise "Type parameter is required!" unless opts.include? "Type"

      @root["Parameters"] ||= {}
      @root["Parameters"][name] = opts
    end

    def specfile
      File.join(File.expand_path(@dir), 'spec.rb')
    end
  end
end
