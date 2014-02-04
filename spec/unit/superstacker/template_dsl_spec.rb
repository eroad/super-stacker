require 'superstacker/template_dsl'
include SuperStacker

describe TemplateDSL do
  it 'should include the cloudformation_functions module' do
    TemplateDSL.included_modules.include? SuperStacker::CloudformationFunctions
  end
end

describe TemplateDSL, 'when compiled' do
  context 'with no declarations' do
    before(:each) do
      @template = TemplateDSL.new('').compile
    end

    it 'should have a default template version' do
      expect(@template['AWSTemplateFormatVersion']).to \
        eq(TemplateDSL::AWSTemplateFormatVersion)
    end
  end

  context 'with a description declared' do
    before(:each) do
      @description = 'test'
      @template = TemplateDSL.new("description '#{@description}'").compile
    end

    it 'should have a description' do
      expect(@template['Description']).to eq(@description)
    end
  end

  context 'with a resource declared' do
    before(:each) do
      @resource = double('resource', :name => 'name', :type => 'type')
      Resource.stub(:new) { @resource }
      @template = TemplateDSL.new('resource "name", "type"').compile
    end

    it 'should add the resource to the resource collection' do
      expect(@template['Resources']['name']).to eq(@resource)
    end
  end

  context 'with a mapping declared' do
    before(:each) do
      @mapping = double('mapping', :name => 'name')
      Mapping.stub(:new) { @mapping }
      @template = TemplateDSL.new('mapping "name"').compile
    end

    it 'should add the mapping to the mapping collection' do
      expect(@template['Mappings']['name']).to eq(@mapping)
    end
  end

  context 'with a parameter declared' do
    before(:each) do
      @template = TemplateDSL.new('parameter "name", "Type" => "String"').compile
    end

    it 'should add the parameter to the parameters collection' do
      expect(@template['Parameters']['name']).to eq({'Type' => 'String'})
    end
  end

  context 'with a output declared' do
    before(:each) do
      @template = TemplateDSL.new('output "name", "value"').compile
    end

    it 'should add the output to the outputs collection' do
      expect(@template['Outputs']['name']).to eq({'Value' => 'value'})
    end
  end
end
