# frozen_string_literal: true

describe Avro::Builder, "#build_dsl" do

  shared_examples_for "dsl for an abstact type" do
    it { is_expected.to be_abstract }
    its(:to_json) { is_expected.to be_json_eql(expected.to_json) }
  end

  context "record" do
    let(:expected) do
      {
        type: :record,
        name: :identifier,
        fields: [
          { type: :long, name: :id },
          { type: :string, name: :name }
        ]
      }
    end

    context "abstract as an option" do
      subject(:dsl) do
        described_class.build_dsl do
          record :identifier, abstract: true do
            required :id, :long
            required :name, :string
          end
        end
      end

      it_behaves_like "dsl for an abstact type"
    end

    context "abstract as a method" do
      subject(:dsl) do
        described_class.build_dsl do
          record :identifier do
            abstract true
            required :id, :long
            required :name, :string
          end
        end
      end

      it_behaves_like "dsl for an abstact type"
    end
  end

  context "enum" do
    let(:expected) do
      { type: :enum, name: :letters, symbols: ['A', 'B', 'C'] }
    end

    context "abstract as an option" do
      subject(:dsl) do
        described_class.build_dsl do
          enum :letters, symbols: ['A', 'B', 'C'], abstract: true
        end
      end

      it_behaves_like "dsl for an abstact type"
    end

    context "abstract as a method" do
      subject(:dsl) do
        described_class.build_dsl do
          enum :letters do
            symbols ['A', 'B', 'C']
            abstract true
          end
        end
      end

      it_behaves_like "dsl for an abstact type"
    end
  end

  context "fixed" do
    let(:expected) do
      { type: :fixed, name: :ssn, size: 11 }
    end

    context "abstract as an option" do
      subject(:dsl) do
        described_class.build_dsl do
          fixed :ssn, size: 11, abstract: true
        end
      end

      it_behaves_like "dsl for an abstact type"
    end

    context "abstract as a method" do
      subject(:dsl) do
        described_class.build_dsl do
          fixed :ssn do
            size 11
            abstract true
          end
        end
      end

      it_behaves_like "dsl for an abstact type"
    end
  end

  context "type macro" do
    subject(:dsl) do
      described_class.build_dsl do
        type_macro :string_map, map(:string)
      end
    end

    let(:expected) do
      { type: :map, values: :string }
    end

    it_behaves_like "dsl for an abstact type"
  end
end
