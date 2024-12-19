# frozen_string_literal: true

describe Avro::Builder, ".extra_metadata_attributes" do
  before do
    Avro::Builder.extra_metadata_attributes(:reference, :deprecated_by)
  end

  context "applying attributes to fields in a record" do
    subject(:schema_json) do
      described_class.build do
        record :r do
          required :n, :null
          required :b, :boolean, reference: 'com.example.bool', deprecated_by: 'com.example.bool_v2', other: 'value'
          required :s, :string
          required :i, :int
          optional :l, :long do
            doc 'A long value'
            order 'ascending'
            reference 'com.example.long'
            deprecated_by 'com.example.long_v2'
          end
          required :f, :float
          optional :d, :double
          required :many_bits, :bytes
        end
      end
    end

    let(:expected) do
      {
        type: :record,
        name: :r,
        fields: [
          { name: :n, type: :null },
          { name: :b, type: :boolean, reference: 'com.example.bool', deprecated_by: 'com.example.bool_v2' },
          { name: :s, type: :string },
          { name: :i, type: :int },
          {
            name: :l,
            type: [:null, :long],
            default: nil,
            doc: 'A long value',
            order: 'ascending',
            reference: 'com.example.long',
            deprecated_by: 'com.example.long_v2'
          },
          { name: :f, type: :float },
          { name: :d, type: [:null, :double], default: nil },
          { name: :many_bits, type: :bytes }
        ]
      }
    end

    it { is_expected.to be_json_eql(expected.to_json) }
  end
end
