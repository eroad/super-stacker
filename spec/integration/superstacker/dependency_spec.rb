require 'superstacker/stack'
require 'superstacker/dependency'

def dummy_stack(name, parameters, outputs, derived={})
  entity = StackEntity.new
  entity.outputs = Hash[outputs.map { |o| [o,nil] }]
  entity.parameters = Hash[parameters.map { |p| [p,nil] }]
  entity.template = { 'Outputs' => entity.outputs,
                      'Parameters' => entity.parameters }

  SuperStacker::Stack.new(name, entity, derived: derived)
end

describe SuperStacker::Dependency::Graph do
  let(:graph) { SuperStacker::Dependency::Graph.new(stacks) }

  context 'given a 3 generational collection of stacks' do
    let(:parent) { dummy_stack('Parent', ['ParentInputA'], ['ParentOutputA']) }
    let(:child) do
      dummy_stack('Child', ['ParentOutputA', 'ChildInputA'], ['ChildOutputA'])
    end
    let(:grandchild) do
      dummy_stack('Grandchild',
                  ['ParentOutputA', 'ChildOutputA', 'GrandchildInputA'],
                  ['GrandchildOutputA'])
    end
    let(:stacks) { StackCollection.new([ parent, child, grandchild ]) }

    specify { expect(graph[parent][:children].count).to eq(2) }
    specify { expect(graph[parent][:children]).to include child }
    specify { expect(graph[parent][:children]).to include grandchild }
    specify { expect(graph[parent][:parents]).to be_empty }

    specify { expect(graph[child][:parents].count).to eq(1) }
    specify { expect(graph[child][:parents]).to include parent }
    specify { expect(graph[child][:children].count).to eq(1) }
    specify { expect(graph[child][:children]).to include grandchild }

    specify { expect(graph[grandchild][:children]).to be_empty }
    specify { expect(graph[grandchild][:parents].count).to eq(2) }
    specify { expect(graph[grandchild][:parents]).to include child }
    specify { expect(graph[grandchild][:parents]).to include parent }

    describe '#find_build_order' do
      specify { expect(SuperStacker::Dependency.find_build_order(graph)).
        to eq([parent, child, grandchild]) }
    end
  end

  context 'given two sibling stacks with the same output ' do
    let(:stacks) { StackCollection.new([ dummy_stack('SiblingA', [], ['OutputX']),
                                         dummy_stack('SiblingB', [], ['OutputX']) ]) }
    
    it 'is not possible to create our dependency graph' do
      expect { SuperStacker::Dependency::Graph.new(stacks) }.
          to raise_error('there be duplicates')
    end
  end

  context 'given a set of stacks with a dervied parameter' do
    let(:parent) { dummy_stack('Parent', [], ['OutputA']) }
    let(:child) { dummy_stack('Child', ['InputA'], [], {'InputA' => { from: 'OutputA' } }) }
    let(:stacks) { StackCollection.new([parent, child]) }

    specify { expect(graph[parent][:children]).to include child }
    specify { expect(graph[parent][:children].count).to eq(1) }
    specify { expect(graph[child][:parents]).to include parent }
    specify { expect(graph[child][:parents].count).to eq(1) }

    describe '#find_build_order' do
      specify { expect(SuperStacker::Dependency.find_build_order(graph)).
                       to eq([parent, child]) }
    end
  end

end
