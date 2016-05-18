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

  context "enum with symbols in hash" do
    subject do
      described_class.build do
        enum :enum1, symbols: [:ONE, :TWO], doc: 'Uses hash'
      end
    end
    let(:expected) do
      {
        name: :enum1,
        type: :enum,
        doc: 'Uses hash',
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

  context "enum with block" do
    subject do
      described_class.build do
        enum do
          name :enum3
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

  context "enum without symbols" do
    subject do
      described_class.build_schema do
        enum :broken_enum
      end
    end

    it "is invalid" do
      expect { subject }
        .to raise_error(Avro::Builder::RequiredAttributeError,
                        "attribute :symbols missing for 'broken_enum' of type :enum")
    end
  end

  context "enum without name" do
    subject do
      described_class.build_schema do
        enum do
          symbols %(A B)
        end
      end
    end

    it "is invalid" do
      expect { subject }
        .to raise_error(Avro::Builder::RequiredAttributeError,
                        'attribute :name missing for type :enum')
    end
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

  context "fixed type with size in hash" do
    subject do
      described_class.build do
        fixed :eight, size: 9
      end
    end
    let(:expected) do
      {
        name: :eight,
        type: :fixed,
        size: 9
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

  context "fixed with block" do
    subject do
      described_class.build do
        fixed do
          name :eight
          size 9
        end
      end
    end
    let(:expected) do
      {
        name: :eight,
        type: :fixed,
        size: 9
      }
    end
    it { is_expected.to be_json_eql(expected.to_json) }
  end

  context "fixed without size" do
    subject do
      described_class.build do
        fixed :broken_fixed
      end
    end

    it "is invalid" do
      expect { subject }
        .to raise_error(Avro::Builder::RequiredAttributeError,
                        "attribute :size missing for 'broken_fixed' of type :fixed")
    end
  end

  context "fixed without name" do
    subject do
      described_class.build do
        fixed do
          size 2
        end
      end
    end

    it "is invalid" do
      expect { subject }
        .to raise_error(Avro::Builder::RequiredAttributeError,
                        'attribute :name missing for type :fixed')
    end
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
          { name: :l, type: [:null, :long], default: nil },
          { name: :f, type: :float },
          { name: :d, type: [:null, :double], default: nil },
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
          { name: :id, type: [:null, :long], default: nil },
          { name: :type, type: :string }
        ]
      }
    end
    it { is_expected.to be_json_eql(expected.to_json) }
  end

  context "record with namespace as an option" do
    subject do
      described_class.build do
        record :rec, namespace: 'com.example.foo' do
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
          { name: :id, type: [:null, :long], default: nil },
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
          { name: :e2, type: { type: :enum, name: :__with_enum_e2_enum, symbols: %i(X Y) } }
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
          { name: :f2, type: { name: :__with_fixed_f2_fixed, type: :fixed, size: 6 } }
        ]
      }
    end
    it { is_expected.to be_json_eql(expected.to_json) }
  end

  context "record with inline named fixed and reference to it" do
    subject do
      described_class.build do
        record :with_magic do
          required :magic, :fixed, name: :Magic, size: 4
          required :more_magic, :Magic
        end
      end
    end
    let(:expected) do
      {
        name: :with_magic,
        type: :record,
        fields: [
          { name: :magic, type: { name: :Magic, type: :fixed, size: 4 } },
          { name: :more_magic, type: :Magic }
        ]
      }
    end
    it { is_expected.to be_json_eql(expected.to_json) }
  end

  context "record with reference to anonymous inline fixed" do
    let(:generated_name) { :__with_magic_magic_fixed }
    subject do
      reference = generated_name
      described_class.build do
        record :with_magic do
          required :magic, :fixed, size: 4
          required :more_magic, reference
        end
      end
    end
    let(:expected) do
      {
        name: :with_magic,
        type: :record,
        fields: [
          { name: :magic, type: { name: generated_name, type: :fixed, size: 4 } },
          { name: :more_magic, type: generated_name }
        ]
      }
    end
    it { is_expected.to be_json_eql(expected.to_json) }
  end


  context "record with repeated definition of inline named fix" do
    subject do
      described_class.build do
        record :with_magic do
          required :magic, :fixed, name: :Magic, size: 4
          required :more_magic, :fixed, name: :Magic, size: 5
        end
      end
    end
    let(:expected) do
      {
        name: :with_magic,
        type: :record,
        fields: [
          { name: :magic, type: { name: :Magic, type: :fixed, size: 4 } },
          { name: :more_magic, type: { name: :Magic, type: :fixed, size: 5 } }
        ]
      }
    end
    it "raises an error" do
      expect { subject }.to raise_error(Avro::Builder::DuplicateDefinitionError)
    end
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
          { name: :maybe_id, type: [:null, :id], default: nil },
          { name: :must_enum, type: { name: :e, type: :enum, symbols: %i(X Y Z) } },
          { name: :maybe_enum, type: [:null, :e], default: nil }
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
          {
            name: :maybe_enum,
            default: nil,
            type: [:null,
                   { name: :e, type: :enum, symbols: %i(A B), namespace: 'com.example' }]
          },
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
          required :pkey, 'com.example.one.id'
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
          { name: :first, type: [:null, :string], default: nil },
          { name: :second, type: :int }
        ]
      }
    end
    it { is_expected.to be_json_eql(expected.to_json) }
  end

  context "record without name" do
    subject do
      described_class.build do
        record do
          required :i, :int
        end
      end
    end

    it "is invalid" do
      expect { subject }
        .to raise_error(Avro::Builder::RequiredAttributeError,
                        'attribute :name missing for type :record')
    end
  end

  context "union" do
    subject do
      described_class.build do
        record :record_with_union do
          required :s_or_i, :union, types: %i(string int)
        end
      end
    end
    let(:expected) do
      {
        type: :record,
        name: :record_with_union,
        fields: [
          { name: :s_or_i, type: [:string, :int] }
        ]
      }
    end
    it { is_expected.to be_json_eql(expected.to_json) }
  end

  context "optional union" do
    subject do
      described_class.build do
        record :record_with_optional_union do
          optional :s_or_i, :union, types: %i(string int)
        end
      end
    end
    let(:expected) do
      {
        type: :record,
        name: :record_with_optional_union,
        fields: [
          { name: :s_or_i, type: [:null, :string, :int], default: nil }
        ]
      }
    end
    it { is_expected.to be_json_eql(expected.to_json) }
  end

  context "optional union that contains null" do
    subject do
      described_class.build do
        record :record_with_opt_union_with_null do
          optional :s_or_i, :union, types: %i(string null int)
        end
      end
    end
    let(:expected) do
      {
        type: :record,
        name: :record_with_opt_union_with_null,
        fields: [
          { name: :s_or_i, type: [:null, :string, :int], default: nil }
        ]
      }
    end
    it { is_expected.to be_json_eql(expected.to_json) }
  end

  context "union with references to named types" do
    subject do
      described_class.build do
        fixed :f_type, 5
        enum :e_type, :A, :B
        record :rec do
          required :s, :string
        end

        record :union_with_refs do
          required :u, :union, types: %i(f_type e_type rec)
        end
      end
    end
    let(:expected) do
      {
        type: :record,
        name: :union_with_refs,
        fields: [
          {
            name: :u,
            type: [
              { name: :f_type, type: :fixed, size: 5 },
              { name: :e_type, type: :enum, symbols: %i(A B) },
              { name: :rec, type: :record, fields: [{ name: :s, type: :string }] }
            ]
          }
        ]
      }
    end
    it { is_expected.to be_json_eql(expected.to_json) }
  end

  context "union with repeated reference" do
    subject do
      described_class.build do
        fixed :f_type, 5

        record :union_with_repeated_ref do
          required :g, :f_type
          required :u, :union, types: %i(null f_type)
        end
      end
    end
    let(:expected) do
      {
        type: :record,
        name: :union_with_repeated_ref,
        fields: [
          { name: :g, type: { name: :f_type, type: :fixed, size: 5 } },
          { name: :u, type: [:null, :f_type] }
        ]
      }
    end
    it { is_expected.to be_json_eql(expected.to_json) }
  end

  context "union without types" do
    subject do
      described_class.build do
        record :broken_union do
          required :u, :union
        end
      end
    end

    it "is invalid" do
      expect { subject }
        .to raise_error(Avro::Builder::RequiredAttributeError,
                        "attribute :types missing for field 'u' of type :union")
    end
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

  context "map without values type" do
    subject do
      described_class.build do
        record :broken_map do
          required :m, :map
        end
      end
    end

    it "is invalid" do
      expect { subject }
        .to raise_error(Avro::Builder::RequiredAttributeError,
                        "attribute :values missing for field 'm' of type :map")
    end
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

  context "array without items type" do
    subject do
      described_class.build do
        record :broken_array do
          required :a, :array
        end
      end
    end

    it "is invalid" do
      expect { subject }
        .to raise_error(Avro::Builder::RequiredAttributeError,
                        "attribute :items missing for field 'a' of type :array")
    end
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

  context "record with subrecord reference" do
    subject do
      described_class.build do
        record :sub_rec do
          namespace 'com.example.A'
          required :i, :int
        end

        record :top_rec do
          namespace 'com.example.B'
          required :sub, 'com.example.A.sub_rec'
        end
      end
    end
    let(:expected) do
      {
        name: :top_rec,
        namespace: 'com.example.B',
        type: :record,
        fields: [
          {
            name: :sub,
            type: {
              name: :sub_rec,
              namespace: 'com.example.A',
              type: :record,
              fields: [{ name: :i, type: :int }]
            }
          }
        ]
      }
    end
    it { is_expected.to be_json_eql(expected.to_json) }
  end

  context "inline, nested record" do
    subject do
      described_class.build do
        namespace 'com.example'

        record :my_rec do
          required :nested, :record do
            required :s, :string
          end
        end
      end
    end
    let(:expected) do
      {
        name: :my_rec,
        namespace: 'com.example',
        type: :record,
        fields: [{
          name: :nested,
          type: {
            name: :__my_rec_nested_record,
            namespace: 'com.example',
            type: :record,
            fields: [{ name: :s, type: :string }]
          }
        }]
      }
    end
    it { is_expected.to be_json_eql(expected.to_json) }
  end

  context "inline, nested record with namespace" do
    subject do
      described_class.build do
        namespace 'com.example'

        record :my_rec do
          required :nested, :record do
            namespace 'com.example.sub'
            required :s, :string
          end
        end
      end
    end
    let(:expected) do
      {
        name: :my_rec,
        namespace: 'com.example',
        type: :record,
        fields: [{
          name: :nested,
          type: {
            name: :__my_rec_nested_record,
            namespace: 'com.example.sub',
            type: :record,
            fields: [{ name: :s, type: :string }]
          }
        }]
      }
    end
    it { is_expected.to be_json_eql(expected.to_json) }
  end

  context "triple-nested record" do
    subject do
      described_class.build do
        namespace 'com.example'
        record :A do
          required :B, :record do
            required :C, :record do
              required :s, :string
              optional :i, :int
            end
          end
          required :C, :record do
            doc 'This record has a unique generated name'
            optional :b, :bytes
          end
        end
      end
    end
    let(:expected) do
      {
        name: :A,
        namespace: 'com.example',
        type: :record,
        fields: [{
          name: :B,
          type: {
            name: :__A_B_record,
            namespace: 'com.example',
            type: :record,
            fields: [{
              name: :C,
              type: {
                name: :__A_B_C_record,
                namespace: 'com.example',
                type: :record,
                fields: [{ name: :s, type: :string },
                         { name: :i, type: [:null, :int], default: nil }]
              }
            }]
          }
        },
                 {
                   name: :C,
                   type: {
                     name: :__A_C_record,
                     namespace: 'com.example',
                     type: :record,
                     fields: [
                       { name: :b, type: [:null, :bytes], default: nil }
                     ]
                   },
                   doc: 'This record has a unique generated name'
                 }]
      }
    end
    it { is_expected.to be_json_eql(expected.to_json) }
  end


  context "inline, named, nested record" do
    subject do
      described_class.build do
        record :my_rec do
          namespace 'com.example'
          required :nested, :record do
            name :nested_rec
            required :s, :string
          end
        end
      end
    end
    let(:expected) do
      {
        name: :my_rec,
        namespace: 'com.example',
        type: :record,
        fields: [{
          name: :nested,
          type: {
            name: :nested_rec,
            namespace: 'com.example',
            type: :record,
            fields: [{ name: :s, type: :string }]
          }
        }]
      }
    end
    it { is_expected.to be_json_eql(expected.to_json) }
  end

  context "ambiguous reference requiring namespacing" do
    subject do
      described_class.build do
        fixed :a_fix, size: 5, namespace: :test
        fixed :a_fix, size: 6, namespace: :other
        fixed :a_fix, size: 7, namespace: :third

        record :with_a_fix do
          required :fix, :a_fix
        end
      end
    end
    it "raises an error" do
      expect { subject }.to raise_error(Avro::Builder::DefinitionNotFoundError)
    end
  end

  context "reference in a different namespace" do
    subject do
      described_class.build do
        enum :my_enum, :A, namespace: :outer

        record :enum_ref, namespace: :inner do
          # Reference works even though it is in another namespace
          required :e, :my_enum
        end
      end
    end
    let(:expected) do
      {
        type: :record,
        name: :enum_ref,
        namespace: :inner,
        fields: [
          {
            name: :e,
            type: {
              type: :enum,
              name: :my_enum,
              namespace: :outer,
              symbols: %w(A)
            }
          }
        ]
      }
    end
    it { is_expected.to be_json_eql(expected.to_json) }
  end

  context "references requiring namespacing" do
    subject do
      described_class.build do
        import 'test.ambiguous'
        import 'other.ambiguous'

        record :with_ambiguous do
          required :rec, 'test.ambiguous'
        end
      end
    end
    let(:expected) do
      {
        name: :with_ambiguous,
        type: :record,
        fields: [
          {
            name: :rec,
            type: {
              type: :record,
              name: :ambiguous,
              namespace: :test,
              fields: [{ name: :i, type: :int }]
            }
          }
        ]
      }
    end
    it { is_expected.to be_json_eql(expected.to_json) }
  end
end
