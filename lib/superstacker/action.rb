require 'aws-sdk'
require 'json'

module SuperStacker
  module Action

    class StatusWatcher
      attr_reader :stack
      
      def initialize(stack)
        @stack = stack
        @cfm = AWS::CloudFormation.new
      end

      def update!
        @stack = @cfm.stacks[@stack.name]
        @stack.status
      end

      # TODO: These statuses need testing. Hopefully we don't have to define
      #       happy paths..

      def complete?
        [ 'CREATE_COMPLETE', 'ROLLBACK_COMPLETE', 'DELETE_COMPLETE',
          'UPDATE_COMPLETE', 'UPDATE_ROLLBACK_COMPLETE', 'CREATE_COMPLETE',
          'ROLLBACK_COMPLETE', 'DELETE_COMPLETE', 'UPDATE_COMPLETE',
          'UPDATE_ROLLBACK_COMPLETE' ].include? @stack.status
      end

      def in_progress?
        [ 'CREATE_IN_PROGRESS', 'ROLLBACK_IN_PROGRESS', 'DELETE_IN_PROGRESS',
          'UPDATE_IN_PROGRESS', 'UPDATE_COMPLETE_CLEANUP_IN_PROGRESS',
          'UPDATE_ROLLBACK_IN_PROGRESS', 'CREATE_IN_PROGRESS', 
          'UPDATE_ROLLBACK_COMPLETE_CLEANUP_IN_PROGRESS', 'ROLLBACK_IN_PROGRESS',
          'DELETE_IN_PROGRESS', 'UPDATE_IN_PROGRESS',
          'UPDATE_COMPLETE_CLEANUP_IN_PROGRESS', 'UPDATE_ROLLBACK_IN_PROGRESS',
          'UPDATE_ROLLBACK_COMPLETE_CLEANUP_IN_PROGRESS' ].include? @stack.status
      end

      def failed?
        [ 'CREATE_FAILED', 'ROLLBACK_FAILED', 'DELETE_FAILED', 'ROLLBACK_FAILED',
          'UPDATE_ROLLBACK_FAILED', 'CREATE_FAILED', 'DELETE_FAILED',
          'UPDATE_ROLLBACK_FAILED' ].include? @stack.status
      end
    end

    module_function
    
    def provision(name, stack)
      cfm = AWS::CloudFormation.new

      new_stack = cfm.stacks.create(name, stack.entity.template,
                                    {:parameters => stack.entity.parameters, :capabilities => ['CAPABILITY_IAM']})

      StatusWatcher.new(new_stack)
    end

    def update(name, stack)
      cfm = AWS::CloudFormation.new
      cfm_stack = cfm.stacks[name]

      cfm_stack.update({ :template => stack.entity.template,
                         :parameters => stack.entity.parameters, :capabilities => ['CAPABILITY_IAM']})

      StatusWatcher.new(cfm_stack)
    end
  end
end
