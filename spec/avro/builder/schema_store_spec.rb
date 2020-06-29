# frozen_string_literal: true

require 'spec_helper'

describe Avro::Builder::SchemaStore do
  describe "#find" do
    subject(:schema) { schema_store.find(name, namespace) }

    let(:schema_store) { described_class.new }
    let(:name) { 'with_array' }
    let(:namespace) { 'test' }

    context "when the dsl directory has not been added to build path" do
      before do
        allow(Avro::Builder::DSL).to receive(:load_paths) { Set.new }
      end

      it "raises a file not found exception" do
        expect { schema }.to raise_error(::Avro::Builder::FileHandler::FileNotFoundError)
      end
    end

    context "when the dsl directory has been added to build path" do
      it { is_expected.to be_a(Avro::Schema) }

      context "when the schema has already been requested" do
        let!(:previous_schema) { schema_store.find(name, namespace) }

        it "returns the cached schema" do
          allow(Avro::Builder).to receive(:find)
          expect(schema).to equal(previous_schema)
          expect(Avro::Builder).not_to have_received(:find)
        end
      end

      context "when the file does not define the expected schema" do
        let(:name) { 'inconsistent' }

        it "raises a schema error" do
          expect { schema }
            .to raise_error(Avro::Builder::SchemaError,
                            "expected schema 'surprise' to define type 'test.inconsistent'")
        end
      end
    end
  end
end
