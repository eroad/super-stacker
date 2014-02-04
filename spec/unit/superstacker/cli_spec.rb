describe SuperStacker::Cli do
  subject { Cli.new }

  describe '.stack_from_url' do
    context 'given a cloudformation url' do
      let(:url) { 'cfm://test' }
      
      it 'calls Stack.from_aws' do
        Stack.should_receive(:from_aws).with('test')
        subject.stack_from_url(url)
      end
    end

    context 'given a directory' do
      let(:url) { 'some/path/' }
      it 'calls Stack.from_dir' do
        Stack.should_receive(:from_dir)
        subject.stack_from_url(url)
      end
    end
  end

  describe '.fetch_params' do

    let(:stacks) {
      entity = StackEntity.new
      entity.template = {}
      entity.parameters = {}
      entity.outputs = {}

      derived = {'DerivedParam' => {:from => 'SomeParam', :block => Proc.new}}
      Stack.new('name', entity, {})
    }

    context 'when given named parameters' do
      let(:params) { [ 'SomeParam=SomeValue' ] }
    end
    
  end

  describe '.resolve_parameter' do
  end

  describe '.load_params' do
  end

  describe '.parse_params' do
    context 'given a array of k=v pairs' do
      let(:params) { [ 'key1=value1', 'key2=value2' ] }
      it 'returns a hash of the k=v pairs' do
        expect(subject.parse_params(params))
          .to eq({'key1' => 'value1', 'key2' => 'value2'})
      end
    end

    context 'given a regular array' do
      let(:params) { [ 'arg1', 'arg2' ] }
      it 'returns the provided params' do
        expect(subject.parse_params(params))
          .to eq(params)
      end
    end
  end
  
end
