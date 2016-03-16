require 'spec_helper'

describe Avro::Builder do
  it "has a version number" do
    expect(Avro::Builder::VERSION).not_to be nil
  end

  context "enum type" do
    subject do
      described_class.build do
        enum :enum1, :ONE, :TWO
      end
    end
    let(:expected) do
      {
        name: :enum1,
        type: :enum,
        symbols: [:ONE, :TWO]
      }
    end
    it { is_expected.to be_json_eql(expected.to_json) }
  end

  context "enum type with options" do
    subject do
      described_class.build do
        enum :enum2, :ONE, :TWO do
          namespace 'com.example'
          doc 'Example Enum'
          aliases %w(Foo Bar)
        end
      end
    end
    let(:expected) do
      {
        name: :enum2,
        type: :enum,
        doc: 'Example Enum',
        aliases: %w(Foo Bar),
        symbols: [:ONE, :TWO],
        namespace: 'com.example'
      }
    end
    it { is_expected.to be_json_eql(expected.to_json) }
  end

  context "enum with symbols splat" do
    subject do
      described_class.build do
        enum :enum3 do
          symbols :A, :B
        end
      end
    end
    let(:expected) do
      {
        name: :enum3,
        type: :enum,
        symbols: [:A, :B]
      }
    end
    it { is_expected.to be_json_eql(expected.to_json) }
  end

  context "enum with symbols array" do
    subject do
      described_class.build do
        enum :enum3 do
          symbols [:A, :B]
        end
      end
    end
    let(:expected) do
      {
        name: :enum3,
        type: :enum,
        symbols: [:A, :B]
      }
    end
    it { is_expected.to be_json_eql(expected.to_json) }
  end

  context "fixed type" do
    subject do
      described_class.build do
        fixed :eight, 8
      end
    end
    let(:expected) do
      {
        name: :eight,
        type: :fixed,
        size: 8
      }
    end
    it { is_expected.to be_json_eql(expected.to_json) }
  end

  context "fixed type with options" do
    subject do
      described_class.build do
        fixed :seven do
          size 7
          aliases ['MoreThanSix']
          namespace 'com.example'
        end
      end
    end
    let(:expected) do
      {
        name: :seven,
        type: :fixed,
        aliases: ['MoreThanSix'],
        size: 7,
        namespace: 'com.example'
      }
    end
    it { is_expected.to be_json_eql(expected.to_json) }
  end

  context "record" do
    subject do
      described_class.build do
        record :r do
          required :n, :null
          required :b, :boolean
          required :s, :string
          required :i, :int
          optional :l, :long
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
          { name: :b, type: :boolean },
          { name: :s, type: :string },
          { name: :i, type: :int },
          { name: :l, type: [:null, :long] },
          { name: :f, type: :float },
          { name: :d, type: [:null, :double] },
          { name: :many_bits, type: :bytes }
        ]
      }
    end
    it { is_expected.to be_json_eql(expected.to_json) }
  end

  context "record with namespace" do
    subject do
      described_class.build do
        namespace 'com.example.foo'

        record :rec do
          optional :id, :long
          required :type, :string
        end
      end
    end
    let(:expected) do
      {
        type: :record,
        name: :rec,
        namespace: 'com.example.foo',
        fields: [
          { name: :id, type: [:null, :long] },
          { name: :type, type: :string }
        ]
      }
    end
    it { is_expected.to be_json_eql(expected.to_json) }
  end

  context "record with inline enum" do
    subject do
      described_class.build do
        record :with_enum do
          required :e1, :enum do
            name :e_enum
            symbols :A, :B
          end
          required :e2, :enum, symbols: [:X, :Y]
        end
      end
    end
    let(:expected) do
      {
        name: :with_enum,
        type: :record,
        fields: [
          { name: :e1, type: { type: :enum, name: :e_enum, symbols: %i(A B) } },
          { name: :e2, type: { type: :enum, name: :__e2_enum, symbols: %i(X Y) } }
        ]
      }
    end
    it { is_expected.to be_json_eql(expected.to_json) }
  end

  context "record with inline fixed" do
    subject do
      described_class.build do
        record :with_fixed do
          required :f1, :fixed do
            name :f5
            size 5
          end
          required :f2, :fixed, size: 6
        end
      end
    end
    let(:expected) do
      {
        name: :with_fixed,
        type: :record,
        fields: [
          { name: :f1, type: { name: :f5, type: :fixed, size: 5 } },
          { name: :f2, type: { name: :__f2_fixed, type: :fixed, size: 6 } }
        ]
      }
    end
    it { is_expected.to be_json_eql(expected.to_json) }
  end

  context "record with type references" do
    subject do
      described_class.build do
        fixed :id, 8
        enum :e, :X, :Y, :Z

        record :refs do
          required :must_id, :id
          optional :maybe_id, :id
          required :must_enum, :e
          optional :maybe_enum, :e
        end
      end
    end
    let(:expected) do
      {
        type: :record,
        name: :refs,
        fields: [
          { name: :must_id, type: { name: :id, type: :fixed, size: 8 } },
          { name: :maybe_id, type: [:null, :id] },
          { name: :must_enum, type: { name: :e, type: :enum, symbols: %i(X Y Z) } },
          { name: :maybe_enum, type: [:null, :e] }
        ]
      }
    end
    it { is_expected.to be_json_eql(expected.to_json) }
  end

  context "record with namespace and references" do
    subject do
      described_class.build do
        namespace 'com.example'

        enum :e, :A, :B

        record :enum_refs do
          optional :maybe_enum, :e
          required :must_enum, :e
        end
      end
    end
    let(:expected) do
      {
        type: :record,
        name: :enum_refs,
        namespace: 'com.example',
        fields: [
          { name: :maybe_enum, type: [:null,
                                      { name: :e, type: :enum, symbols: %i(A B), namespace: 'com.example' }] },
          { name: :must_enum, type: 'com.example.e' }
        ]
      }
    end
    it { is_expected.to be_json_eql(expected.to_json) }
  end

  context "record with reference in another namespace" do
    subject do
      described_class.build do
        namespace 'com.example.one'
        fixed :id, 2

        namespace 'com.example.two'
        record :uses_id do
          required :pkey, :id
        end
      end
    end
    let(:expected) do
      {
        name: :uses_id,
        namespace: 'com.example.two',
        type: :record,
        fields: [
          { name: :pkey, type: { name: :id, namespace: 'com.example.one', type: :fixed, size: 2 } }
        ]
      }
    end
    it { is_expected.to be_json_eql(expected.to_json) }
  end

  context "record that extends another record" do
    subject do
      described_class.build do
        record :shared_id_record do
          required :id, :int, default: 0
        end

        record :usage_record do
          extends :shared_id_record
          required :added, :string
        end
      end
    end
    let(:expected) do
      {
        type: :record,
        name: :usage_record,
        fields: [
          { name: :id, type: :int, default: 0 },
          { name: :added, type: :string }
        ]
      }
    end
    it { is_expected.to be_json_eql(expected.to_json) }
  end

  context "record that extends multiple records" do
    subject do
      described_class.build do
        record :shared_id_record do
          required :id, :int, default: 0
        end
        record :shared_value_record do
          required :value, :string
        end

        record :usage_record do
          extends :shared_id_record
          extends :shared_value_record
        end
      end
    end
    let(:expected) do
      {
        type: :record,
        name: :usage_record,
        fields: [
          { name: :id, type: :int, default: 0 },
          { name: :value, type: :string }
        ]
      }
    end
    it { is_expected.to be_json_eql(expected.to_json) }
  end

  context "record with extends and override" do
    subject do
      described_class.build do
        record :original do
          required :first, :string
          required :second, :int
        end

        record :extended do
          extends :original
          optional :first, :string
        end
      end
    end
    let(:expected) do
      {
        type: :record,
        name: :extended,
        fields: [
          { name: :first, type: [:null, :string] },
          { name: :second, type: :int }
        ]
      }
    end
    it { is_expected.to be_json_eql(expected.to_json) }
  end

  context "map" do
    subject do
      described_class.build do
        record :record_with_map do
          required :stringy_map, :map, values: :string
        end
      end
    end
    let(:expected) do
      {
        type: :record,
        name: :record_with_map,
        fields: [
          { name: :stringy_map, type: { type: :map, values: :string } }
        ]
      }
    end
    it { is_expected.to be_json_eql(expected.to_json) }
  end

  context "map with named type" do
    subject do
      described_class.build do
        enum :alpha, :A, :B

        record :map_with_named_type do
          required :named_map, :map, values: :alpha
        end
      end
    end
    let(:expected) do
      {
        type: :record,
        name: :map_with_named_type,
        fields: [
          { name: :named_map, type: { type: :map, values: { type: :enum, name: :alpha, symbols: %i(A B) } } }
        ]
      }
    end
    it { is_expected.to be_json_eql(expected.to_json) }
  end

  context "array" do
    subject do
      described_class.build do
        record :record_with_array do
          required :ary_of_ints, :array, items: :int
        end
      end
    end
    let(:expected) do
      {
        type: :record,
        name: :record_with_array,
        fields: [
          { name: :ary_of_ints, type: { type: :array, items: :int } }
        ]
      }
    end
    it { is_expected.to be_json_eql(expected.to_json) }
  end

  context "array with named type" do
    subject do
      described_class.build do
        fixed :uuid, 8

        record :array_of_named do
          required :ary, :array, items: :uuid
        end
      end
    end
    let(:expected) do
      {
        type: :record,
        name: :array_of_named,
        fields: [
          { name: :ary, type: { type: :array, items: { type: :fixed, name: :uuid, size: 8 } } }
        ]
      }
    end
    it { is_expected.to be_json_eql(expected.to_json) }
  end

  context "record with extends" do
    subject do
      described_class.build do
        record :base_id do
          required :id, :long
        end

        record :uses_id do
          extends :base_id
          required :value, :string
        end
      end
    end
    let(:expected) do
      {
        name: :uses_id,
        type: :record,
        fields: [
          { name: :id, type: :long },
          { name: :value, type: :string }
        ]
      }
    end
    it { is_expected.to be_json_eql(expected.to_json) }
  end
end
