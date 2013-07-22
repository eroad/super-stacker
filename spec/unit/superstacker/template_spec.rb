require 'superstacker/template'
include SuperStacker::Template

describe Template do
  it 'should include the cloudformation_functions module' do
    Template.included_modules.include? SuperStacker::CloudformationFunctions
  end
end

describe Template, 'when compiled' do
  context 'with no declarations' do
    before(:each) do
      @template = Template.new('').compile
    end

    it 'should have a default template version' do
      expect(@template['AWSTemplateFormatVersion']).to \
        eq(Template::AWSTemplateFormatVersion)
    end
  end

  context 'with a description declared' do
    before(:each) do
      @description = 'test'
      @template = Template.new("description '#{@description}'").compile
    end

    it 'should have a description' do
      expect(@template['Description']).to eq(@description)
    end
  end

  context 'with a resource declared' do
    before(:each) do
      @resource = double('resource', :name => 'name', :type => 'type')
      Resource.stub(:new) { @resource }
      @template = Template.new('resource "name", "type"').compile
    end

    it 'should add the resource to the resource collection' do
      expect(@template['Resources']['name']).to eq(@resource)
    end
  end

  context 'with a mapping declared' do
    before(:each) do
      @mapping = double('mapping', :name => 'name')
      Mapping.stub(:new) { @mapping }
      @template = Template.new('mapping "name"').compile
    end

    it 'should add the mapping to the mapping collection' do
      expect(@template['Mappings']['name']).to eq(@mapping)
    end
  end

  context 'with a parameter declared' do
    before(:each) do
      @template = Template.new('parameter "name", "Type" => "String"').compile
    end

    it 'should add the parameter to the parameters collection' do
      expect(@template['Parameters']['name']).to eq({'Type' => 'String'})
    end
  end

  context 'with a output declared' do
    before(:each) do
      @template = Template.new('output "name", "value"').compile
    end

    it 'should add the output to the outputs collection' do
      expect(@template['Outputs']['name']).to eq({'Value' => 'value'})
    end
  end
end
