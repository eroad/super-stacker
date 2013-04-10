class ResourceHash < Hash
  # used for declaring resources, works like:
  # ResourceHash.new "name" do
  #   leaf1 "value1"
  #   nested do
  #     leaf2 "value2"
  #   end
  # end
  #
  # would become..
  #
  # { "leaf" => "value, "nested" => { "leaf" => "value } }

  def method_missing(sym, *args, &block)
    raise "Only one argument expected." unless args.length == 1 or block_given?

    if block_given?
      self[sym] ||= ResourceHash.new
      self[sym].instance_eval(&block)
    else
      self[sym] = args[0]
    end
  end
end

class Resource < ResourceHash
  attr_reader :type, :name

  def initialize(name, type, &block)
    @name = name
    @type = type

    self['Type'] = @type

    instance_eval(&block)
  end
end
