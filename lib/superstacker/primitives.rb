module SuperStacker
  module Primitives

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

    class DeclarativeHash < Hash

      # This class implements the DSL, we strip off most of the standard ruby
      # methods to avoid conflicts in the DSL so it's only really useful as a
      # proxy. It is likely to behave in unexpected ways if used for anything
      # else.

      class DSL
        whitelist_methods = [ :instance_eval, :object_id ]

        # here we undefine most inherited methods to avoid conflicts in the DSL
        instance_methods.each do |m|
          undef_method(m) unless (m.match(/^__/)) or whitelist_methods.include? m
        end

        # === Parameters
        #
        # +hash+:: a link back to the hash which the instance is a proxy for
        # +block+:: the block to be instance_eval'd
        def initialize(hash, &block)
          @hash = hash
          instance_eval(&block)
        end

        def method_missing(sym, *args, &block)
          raise 'Only one argument expected.' unless args.length == 1 or block_given?

          if block_given?
            @hash[sym] ||= DeclarativeHash.new
            @hash[sym].dsl_eval(&block)
          else
            @hash[sym] = args[0]
          end
        end

        # We are unable to use most control characters in key names. The escape
        # method allows us to work around this limitation.
        def escape(sym, *args, &block)
          method_missing(sym, *args, &block)
        end
      end

      # evaluate the given block in the context of our DSL
      def dsl_eval(&block)
        DSL.new(self, &block)
      end

      def initialize(&block)
        if block_given?
          dsl_eval(&block)
        end
      end
    end

    class Resource < DeclarativeHash
      attr_reader :type, :name

      def initialize(name, type, &block)
        @name = name
        @type = type

        self['Type'] = @type

        dsl_eval(&block)
      end
    end

    class Mapping < DeclarativeHash
      attr_reader :name

      def initialize(name, &block)
        @name = name

        dsl_eval(&block)
      end
    end
  end
end
