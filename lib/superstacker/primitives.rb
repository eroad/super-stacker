class DeclarativeHash < Hash
  # used for declaring resources, works like:
  # DeclarativeHash.new "name" do
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
    raise 'Only one argument expected.' unless args.length == 1 or block_given?

    if block_given?
      self[sym] ||= DeclarativeHash.new
      self[sym].instance_eval(&block)
    else
      self[sym] = args[0]
    end
  end

  def escape(sym, *args, &block)
    method_missing(sym, *args, &block)
  end
end

class Resource < DeclarativeHash
  attr_reader :type, :name

  def initialize(name, type, &block)
    @name = name
    @type = type

    self['Type'] = @type

    instance_eval(&block)
  end
end

class Mapping < DeclarativeHash
  attr_reader :name

  def initialize(name, &block)
    @name = name

    instance_eval(&block)
  end
end
