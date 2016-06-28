require 'spec_helper'

describe Avro::Builder::SchemaStore do
  describe '#find' do
    subject { schema_store.find(name, namespace) }

    let(:schema_store) { described_class.new }
    let(:name) { 'with_array' }
    let(:namespace) { 'test' }

    context 'dsl directory has not been added to build path' do
      before do
        allow(Avro::Builder::DSL).to receive(:load_paths) { Set.new }
      end

      it 'raises file not found exception' do
        expect{ subject }.to raise_error(RuntimeError)
      end
    end

    context 'dsl directory has been added to build path' do
      it { is_expected.to be_a(Avro::Schema) }

      context 'schema has already been requested' do
        before do
          schema_store.find(name, namespace)
        end

        it 'uses cached schema' do
          expect(Avro::Builder).to_not receive(:find)
          subject
        end
      end
    end
  end
end
