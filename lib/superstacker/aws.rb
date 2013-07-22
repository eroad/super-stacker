require 'aws-sdk'
require 'pry'

module SuperStacker
  module AWS
    module_function

    def load_stack(name)
      cfm = ::AWS::CloudFormation.new
      stack = cfm.stacks[name]
      stack.template
    end

  end
end
