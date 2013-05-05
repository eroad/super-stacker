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

end

def Ref(logicalName)
  { 'Ref' => logicalName }
end
