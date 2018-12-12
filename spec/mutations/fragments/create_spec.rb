require 'spec_helper'

describe Fragments::Create do
  let(:device) { FactoryBot.create(:device) }
  let(:tool)   { FactoryBot.create(:tool, device: device) }
  let(:point)  { FactoryBot.create(:generic_pointer, device: device) }

  H       = CeleryScript::HeapAddress
  KLASSES = [ ArgSet, Fragment, Node, Primitive, PrimitivePair, StandardPair ]

  fit "loads CeleryScript from the database" do
    tool     = FactoryBot.create(:tool, device: device)
    flat_ast = Fragments::Preprocessor.run!(device: device,
            kind:   "farm_event",
            args:   {},
            body:   [
              {
                kind: "variable_declaration",
                args: {
                  label: "myLabel123",
                  data_value: {
                    kind: "coordinate",
                    args: { x: 0, y: 1, z: 2, }
                  }
                }
              },
              {
                kind: "variable_declaration",
                args: {
                  label: "other thing",
                  data_value: {
                    kind: "tool",
                    args: { tool_id: tool.id }
                  }
                }
              }
            ])
    fragment = Fragments::Create.run!(device: device, flat_ast: flat_ast)
    nodes    = fragment.nodes.sort_by(&:id)
    entry    = nodes[1]

    expect(entry.kind.value).to       eq("farm_event")
    expect(entry.next.kind.value).to  eq("nothing")
    expect(entry.body.kind.value).to  eq("variable_declaration")
    other_thing = entry.body.next
    expect(other_thing.kind.value).to eq("variable_declaration")
    pair = other_thing.arg_set.standard_pairs.first
    ArgName.find(pair.arg_name_id)
    binding.pry
    expect(other_thing.next.kind.value).to eq("nothing")
  end

  it "dumps CeleryScript into the database" do
    flat_ast = [ { :__KIND__     => "nothing",
                      :__parent     => H[0],
                      :__body       => H[0],
                      :__next       => H[0] },
                    { :__KIND__     => "farm_event",
                      :__parent     => H[0],
                      :__body       => H[2],
                      :__next       => H[0] },
                    { :__KIND__     => "variable_declaration",
                      :__parent     => H[1],
                      :label        => "foo",
                      :__data_value => H[3],
                      :__body       => H[0],
                      :__next       => H[0] },
                    { :__KIND__     => "identifier",
                      :__parent     => H[2],
                      :label        => "makes no sense",
                      :data_type    => "coordinate",
                      :__body       => H[0],
                      :__next       => H[0] } ]

    Node.destroy_all
    Fragment.destroy_all
    b4_counts = KLASSES.reduce({}) do |acc, klass|
      acc[klass] = klass.count
      acc
    end
    fragment = Fragments::Create.run!(device: device, flat_ast: flat_ast)
    KLASSES.map { |k| flunk "#{k} did not save" if k.count <= b4_counts[k] }
    nodes = fragment.nodes.sort_by(&:id);
    expect(nodes[0].kind.value).to eq("nothing")
    expect(nodes[1].kind.value).to eq("farm_event")
    expect(nodes[2].kind.value).to eq("variable_declaration")
    expect(nodes[3].kind.value).to eq("identifier")
    expect(nodes[3].arg_set.primitive_pairs.count).to eq 2
    Node.destroy_all
    Fragment.destroy_all
    expect(ArgSet.count).to eq(0)
    expect(Node.count).to eq(0)
    expect(PrimitivePair.count).to eq(0)
    expect(StandardPair.count).to eq(0)
    expect(Primitive.count).to eq(0)
  end
end
