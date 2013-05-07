def superstacker(command='')
  `bundle exec super-stacker #{command}`
end

describe 'cli' do
  context 'when called with no arguments' do
    it 'should return 1' do
      superstacker

      expect($?).to eq(0)
    end

    it 'should output the help message' do
      output = superstacker

      output.should =~ /^Tasks:/
    end
  end

  context 'when the examples are compiled' do
    it 'should match our known good output' do
      Dir.glob('examples/*').each do |example|
        output = superstacker "stack #{example}"

        known_file = File.join(example, 'spec.json')
        known_output = File.open(known_file) { |f| f.read }

        expect(output).to eq(known_output)
      end
    end
  end
end
