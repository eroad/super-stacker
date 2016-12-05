module SuperStacker
  module CloudformationFunctions
    module Fn

      def self.Base64(string)
        { 'Fn::Base64' => string }
      end

      def self.FindInMap(map, key, value)
        { 'Fn::FindInMap' => [ map, key, value ] }
      end

      def self.GetAtt(resource_name, attribute_name)
        { 'Fn::GetAtt' => [ resource_name, attribute_name ] }
      end

      def self.GetAZs(region='')
        { 'Fn::GetAZs' => region }
      end

      def self.Join(on, list)
        { 'Fn::Join' => [ on, list ] }
      end

      def self.Select(index, list)
        { 'Fn::Select' => [ index, list ] }
      end

      def self.Sub(string, variables=nil)
        if variables.nil?
          { 'Fn::Sub' => string }
        else
          { 'Fn::Sub' => [string, variables] }
        end
      end

    end

  end
end

# TODO: Figure out how to get this into the AwsFunctions module.
# For some reason this function isn't available within blocks in templates
# when included into the Template class. I'm defining it at the base of the
# module namespace as a work around as this seems to get around the issue.
def Ref(logicalName)
  { 'Ref' => logicalName }
end
