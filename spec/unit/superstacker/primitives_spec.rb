require 'superstacker/primitives'
include SuperStacker::Primitives

describe DeclarativeHash do
  it 'allows us to declare a hash using a block' do
    hash = DeclarativeHash.new do
      SomeKey 'SomeValue'
    end

    expect(hash[:SomeKey]).to eq('SomeValue')
  end

  it 'allows us to specify a hash within a hash using a block within a block' do
    hashception = DeclarativeHash.new do
      hash_within_a_hash do
        some_key 'some_value'
      end
    end

    expect(hashception[:hash_within_a_hash][:some_key]).to eq('some_value')
  end

  it 'hides the hash instance methods when in a block' do
    hash = DeclarativeHash.new do
      key 'value'
    end

    expect(hash[:key]).to eq('value')
  end
end

describe Resource do
  it 'compiles into a CloudFormation resource' do
    resource = Resource.new 'name', 'type' do
    end

    expect(resource.type).to eq('type')
    expect(resource.name).to eq('name')
  end

  it 'correctly extends DeclarativeHash' do
    expect(Resource < DeclarativeHash).to be_truthy

    resource = Resource.new 'name', 'type' do
      key 'value'
    end

    expect(resource[:key]).to eq('value')
  end
end

describe Mapping do
  it 'compiles into a CloudFormation mapping' do
    mapping = Mapping.new 'name' do
    end

    expect(mapping.name).to eq('name')
  end

  it 'correctly extends DeclarativeHash' do
    expect(Mapping < DeclarativeHash).to be_truthy

    resource = Mapping.new 'name' do
      key 'value'
    end

    expect(resource[:key]).to eq('value')
  end
end
