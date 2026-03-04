# frozen_string_literal: true

describe Avro::Builder, ".extra_metadata_attributes" do
  before do
    Avro::Builder.extra_metadata_attributes(:reference, :deprecated_by, :documentation_url)
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

    it "is parseable by the avro gem" do
      expect { Avro::Schema.parse(schema_json) }.not_to raise_error
    end
  end

  context "applying attributes to the record" do
    subject(:schema_json) do
      described_class.build do
        record :r do
          documentation_url 'https://example.com/docs'
          reference 'internal-reference'
          required :b, :boolean
          optional :d, :double
        end
      end
    end

    let(:expected) do
      {
        type: :record,
        name: :r,
        fields: [
          { name: :b, type: :boolean },
          { name: :d, type: [:null, :double], default: nil }
        ],
        documentation_url: 'https://example.com/docs',
        reference: 'internal-reference'
      }
    end

    it { is_expected.to be_json_eql(expected.to_json) }

    it "is parseable by the avro gem" do
      expect { Avro::Schema.parse(schema_json) }.not_to raise_error
    end
  end

  context "applying attributes to an enum" do
    subject(:schema_json) do
      described_class.build do
        enum :status, :ACTIVE, :INACTIVE, reference: 'com.example.status', documentation_url: 'https://example.com/status'
      end
    end

    let(:expected) do
      {
        type: :enum,
        name: :status,
        symbols: [:ACTIVE, :INACTIVE],
        reference: 'com.example.status',
        documentation_url: 'https://example.com/status'
      }
    end

    it { is_expected.to be_json_eql(expected.to_json) }

    it "is parseable by the avro gem" do
      expect { Avro::Schema.parse(schema_json) }.not_to raise_error
    end
  end

  context "applying attributes to a fixed" do
    subject(:schema_json) do
      described_class.build do
        fixed :checksum, 16, reference: 'com.example.checksum'
      end
    end

    let(:expected) do
      {
        type: :fixed,
        name: :checksum,
        size: 16,
        reference: 'com.example.checksum'
      }
    end

    it { is_expected.to be_json_eql(expected.to_json) }

    it "is parseable by the avro gem" do
      expect { Avro::Schema.parse(schema_json) }.not_to raise_error
    end
  end

  context "conflict validation" do
    it "raises an error when an attribute conflicts with an existing attribute" do
      expect do
        Avro::Builder.extra_metadata_attributes(:doc)
      end.to raise_error(ArgumentError, /conflict with existing/)
    end
  end
end
