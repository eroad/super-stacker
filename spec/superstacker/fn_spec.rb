require 'superstacker/fn'

describe Fn do
  it 'returns a CloudFormation Fn::Base64 object' do
    expect(Fn.Base64('string')).to eq({ 'Fn::Base64' => 'string' })
  end

  it 'returns a CloudFormation Fn::FindInMap object' do
    expect(Fn.FindInMap('map', 'key', 'value')).to \
      eq({ 'Fn::FindInMap' => ['map', 'key', 'value'] })
  end

  it 'returns a CloudFormation Fn::Base64 object' do
    expect(Fn.GetAtt('resource', 'attribute')).to \
      eq({ 'Fn::GetAtt' => ['resource', 'attribute'] })
  end

  it 'returns a CloudFormation Fn::Base64 object' do
    expect(Fn.GetAZs('region')).to eq({ 'Fn::GetAZs' => 'region' })
  end

  it 'returns a CloudFormation Fn::Base64 object' do
    expect(Fn.Join(',', ['a', 'b'])).to eq({ 'Fn::Join' => [',', ['a','b']] })
  end

  it 'returns a CloudFormation Fn::Base64 object' do
    expect(Fn.Select('0', [0,1])).to eq({ 'Fn::Select' => ['0', [0,1]] })
  end
end

describe 'Ref' do
  it 'returns a CloudFormation Ref object' do
    expect(Ref('resource')).to eq({ 'Ref' => 'resource' })
  end
end
