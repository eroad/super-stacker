require 'spec_helper'
require 'superstacker/cli'

describe 'super-stacker cli' do
  context 'when called with no arguments' do
    it 'should return 0' do
      `bundle exec super-stacker`

      expect($?).to eq(0)
    end

    it 'should output the help message' do
      output = `bundle exec super-stacker`

      expect(output).to match(/^Tasks:/)
    end
  end
end
