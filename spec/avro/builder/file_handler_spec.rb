require 'spec_helper'

describe Avro::Builder::FileHandler do
  context "loading external references" do
    subject do
      Avro::Builder.build do
        record :with_reference do
          required :external, 'test.external_type'
        end
      end
    end

    let(:expected) do
      {
        type: :record,
        name: :with_reference,
        fields: [
          {
            name: :external,
            type: {
              type: :fixed,
              name: :external_type,
              namespace: :test,
              size: 2
            }
          }
        ]
      }
    end

    it { is_expected.to be_json_eql(expected.to_json) }
  end

  context "loading qualified references" do
    subject do
      Avro::Builder.build do
        record :with_qualified_reference do
          required :external, 'test.external_type'
        end
      end
    end

    let(:expected) do
      {
        type: :record,
        name: :with_qualified_reference,
        fields: [
          {
            name: :external,
            type: {
              type: :fixed,
              name: :external_type,
              namespace: :test,
              size: 2
            }
          }
        ]
      }
    end

    it { is_expected.to be_json_eql(expected.to_json) }
  end

  context "when a reference cannot be resolved" do
    subject(:schema_json) do
      Avro::Builder.build do
        record :with_missing do
          required :ref, :does_not_exist
        end
      end
    end

    it "raises an error" do
      expect { schema_json }.to raise_error(/File not found/)
    end
  end

  context "when a reference is ambiguous" do
    subject(:schema_json) do
      Avro::Builder.build do
        record :with_ambiguous do
          required :ref, :ambiguous
        end
      end
    end

    it "raises an error" do
      expect { schema_json }.to raise_error(/Multiple matches:/)
    end
  end

  context "with duplicated paths" do
    subject(:schema_json) do
      Avro::Builder.build do
        record :with_date do
          required :dt, :date
        end
      end
    end

    let(:expected) do
      {
        type: :record,
        name: :with_date,
        fields: [
          {
            name: :dt,
            type: {
              type: :int,
              logicalType: :date
            }
          }
        ]
      }
    end

    context "subpath" do
      before do
        Avro::Builder.add_load_path('spec/avro/dsl')
        Avro::Builder.add_load_path('spec/avro/dsl/test')
      end

      it { is_expected.to be_json_eql(expected.to_json) }
    end

    context "normalization required" do
      before do
        Avro::Builder.add_load_path('spec/avro/dsl')
        Avro::Builder.add_load_path(File.join(__dir__, '../dsl'))
      end

      it { is_expected.to be_json_eql(expected.to_json) }
    end
  end

  context "a file with a name that ends with a builtin type" do
    let(:file_path) { 'spec/avro/dsl/test/with_array.rb' }
    let(:expected) do
      {
        type: :record,
        name: :with_array,
        namespace: :test,
        fields: [
          { name: :array_of_ints, type: { type: :array, items: :int } }
        ]
      }
    end

    subject(:schema_json) { Avro::Builder.build(File.read(file_path)) }

    it "does not match a partial file name" do
      # previously this triggered an infinite loop
      expect(schema_json).to be_json_eql(expected.to_json)
    end

    it "does not attempt to load 'array' from a file" do
      allow(Avro::Builder::DSL).to receive(:import).and_call_original
      expect(schema_json).to be_json_eql(expected.to_json)
      expect(Avro::Builder::DSL).not_to have_received(:import).with(:array)
    end
  end
end
