require 'pp'

module SuperStacker
  module Dependency

    class Graph
      attr_reader :graph
      
      def initialize(stacks)
        @stacks = stacks
        @graph = {}

        build_graph
      end

      def build_graph
        #outputs = @stacks.map { |s| s.entity.outputs.keys }.flatten
        #duplicates = outputs.select { |o| outputs.count(o) > 1 }.uniq

        if @stacks.duplicate_outputs.any?
          raise 'there be duplicates'
          # TODO: find stacks with duplicate outputs, and print debug output
        end

        @stacks.map { |s| @graph[s] = { children: [], parents: [] } }
        @stacks.each do |stack|
          stack.entity.parameters.keys.each do |p|
            if stack.derived.include? p
              source = stack.derived[p][:from]
              s = @stacks.with_output(source)
            else
              s = @stacks.with_output(p)
            end

            if ! s.nil?
              @graph[s][:children] << stack
              @graph[stack][:parents] << s
            end
          end
        end
      end

      def outputs_to_stacks
        Hash[@stacks.map { |s| s.entity.outputs.keys.map { |o| [o,s] } }.flatten(1)]
      end

      def [](stack)
        @graph[stack]
      end
    end

    module_function

    def find_build_order(graph)
      stacks, order, found = graph.graph.keys, [], false
      while stacks.count > 0
        stacks.each do |stack|
          parents = graph[stack][:parents]
          if parents.count.zero? || parents.map { |p| order.include? p }.all?
            order << stack
            stacks.delete(stack)
            found = true
          end
        end

        # TODO: tidy
        raise 'usolvable' if ! found
      end

      order
    end
  end
end
