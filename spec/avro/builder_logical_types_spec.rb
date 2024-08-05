# frozen_string_literal: true

describe Avro::Builder, 'logical_types' do
  let(:schema) { Avro::Schema.parse(schema_json) }

  def self.with_decimal_validation
    yield if Avro::Schema::FixedSchema.instance_methods.include?(:precision)
  end

  context "primitive types" do
    context "date logical type" do
      subject(:schema_json) do
        described_class.build do
          record :with_date do
            required :d, :int, logical_type: :date
          end
        end
      end

      let(:expected) do
        {
          type: :record,
          name: :with_date,
          fields: [{ name: :d, type: { type: :int, logicalType: :date } }]
        }
      end

      it { is_expected.to be_json_eql(expected.to_json) }

      it "sets the logical type on the field" do
        expect(schema.fields.first.type.logical_type).to eq('date')
      end
    end

    context "timestamp-micros logical type" do
      subject(:schema_json) do
        described_class.build do
          record :with_timestamp_micros do
            required :ts, :long, logical_type: 'timestamp-micros'
          end
        end
      end

      let(:expected) do
        {
          type: :record,
          name: :with_timestamp_micros,
          fields: [{ name: :ts, type: { type: :long, logicalType: 'timestamp-micros' } }]
        }
      end

      it { is_expected.to be_json_eql(expected.to_json) }

      it "sets the logical type on the field" do
        expect(schema.fields.first.type.logical_type).to eq('timestamp-micros')
      end
    end

    context "timestamp-millis logical type" do
      subject(:schema_json) do
        described_class.build do
          record :with_timestamp_millis do
            required :ts, :long, logical_type: 'timestamp-millis'
          end
        end
      end

      let(:expected) do
        {
          type: :record,
          name: :with_timestamp_millis,
          fields: [{ name: :ts, type: { type: :long, logicalType: 'timestamp-millis' } }]
        }
      end

      it { is_expected.to be_json_eql(expected.to_json) }

      it "sets the logical type on the field" do
        expect(schema.fields.first.type.logical_type).to eq('timestamp-millis')
      end
    end

    context "timestamp-nanos logical type" do
      subject(:schema_json) do
        described_class.build do
          record :with_timestamp_nanos do
            required :ts, :long, logical_type: 'timestamp-nanos'
          end
        end
      end

      let(:expected) do
        {
          type: :record,
          name: :with_timestamp_nanos,
          fields: [{ name: :ts, type: { type: :long, logicalType: 'timestamp-nanos' } }]
        }
      end

      it { is_expected.to be_json_eql(expected.to_json) }

      it "sets the logical type on the field" do
        expect(schema.fields.first.type.logical_type).to eq('timestamp-nanos')
      end
    end


    context "decimal bytes logical type" do
      subject(:schema_json) do
        described_class.build do
          record :with_bytes_decimal do
            required :value, :bytes, logical_type: 'decimal', precision: 5, scale: 2
          end
        end
      end

      let(:expected) do
        {
          type: :record,
          name: :with_bytes_decimal,
          fields: [{ name: :value, type: { type: :bytes, logicalType: 'decimal', precision: 5, scale: 2 } }]
        }
      end

      it { is_expected.to be_json_eql(expected.to_json) }

      it "sets the logical type on the field" do
        expect(schema.fields.first.type.logical_type).to eq('decimal')
      end

      context "validation" do
        subject(:schema_json) do
          described_class.build do
            record :with_bytes_decimal do
              required :value, :bytes, logical_type: 'decimal'
            end
          end
        end

        with_decimal_validation do
          it "relies on Avro schema parse to validate" do
            expect do
              schema
            end.to raise_error(Avro::SchemaParseError, 'Precision must be positive')
          end
        end
      end
    end
  end

  context "fixed type" do
    context "duration" do
      # This is not actually supported by ruby avro but demonstrates support for
      # logical_type on the fixed type.

      subject(:schema_json) do
        described_class.build do
          record :with_duration do
            required :dur, :fixed, size: 12, logical_type: 'duration', type_name: :dur_fixed
          end
        end
      end

      let(:expected) do
        {
          type: :record,
          name: :with_duration,
          fields: [{ name: :dur,
                     type: { type: :fixed, size: 12, name: :dur_fixed, logicalType: 'duration' } }]
        }
      end

      it { is_expected.to be_json_eql(expected.to_json) }

      it "sets the logical type on the field" do
        expect(schema.fields.first.type.logical_type).to eq('duration')
      end
    end

    context "decimal" do
      # The decimal logic type is parsed and serialized for fixed schemas but is not yet
      # fully supported (validation, encode/decode)

      subject(:schema_json) do
        described_class.build do
          record 'with_decimal_fixed' do
            required :value, :fixed, size: 8, logical_type: 'decimal', precision: 5, scale: 2, type_name: :dec_fixed
          end
        end
      end

      let(:expected) do
        {
          type: :record,
          name: :with_decimal_fixed,
          fields: [{ name: :value,
                     type: { type: :fixed, size: 8, name: :dec_fixed,
                             logicalType: 'decimal', precision: 5, scale: 2 } }]
        }
      end

      it { is_expected.to be_json_eql(expected.to_json) }

      it "sets the logical type on the field" do
        expect(schema.fields.first.type.logical_type).to eq('decimal')
      end

      context "validation" do
        subject(:schema_json) do
          described_class.build do
            record :with_fixed_decimal do
              required :value, :fixed, size: 8, logical_type: 'decimal', type_name: :dec_fixed
            end
          end
        end

        with_decimal_validation do
          # Avro v1.11.0 does not yet validate fixed decimals
          it "relies on Avro schema parse to validate" do
            expect do
              schema
            end.not_to raise_error(Avro::SchemaParseError)
          end
        end
      end
    end
  end

  context "union type" do
    subject(:schema_json) do
      described_class.build do
        record :with_union do
          required :u, :union, types: [:int, :string], logical_type: :num_or_string
        end
      end
    end

    let(:expected) do
      {
        type: :record,
        name: :with_union,
        fields: [{ name: :u,
                   type: [:int, :string], logicalType: :num_or_string }]
      }
    end

    it "raises an error" do
      expect { schema_json }
        .to raise_error(Avro::Builder::AttributeError,
                        'Logical types are not supported for unions: num_or_string.')
    end
  end

  context "record type" do
    subject(:schema_json) do
      described_class.build do
        record :with_logical_rec do
          required :c, :record, type_name: :complex_num do
            logical_type :complex
            required :real, :double
            optional :imaginary, :double
          end
        end
      end
    end

    let(:expected) do
      {
        type: :record,
        name: :with_logical_rec,
        fields: [{ name: :c,
                   type: {
                     type: :record,
                     name: :complex_num,
                     logicalType: :complex,
                     fields: [
                       { type: :double, name: :real },
                       { type: [:null, :double], name: :imaginary, default: nil }
                     ]
                   } }]
      }
    end

    it { is_expected.to be_json_eql(expected.to_json) }
  end

  context "array of logical types using #type" do
    subject(:schema_json) do
      described_class.build do
        record :with_date_array do
          required :date_array, :array, items: type(:int, logical_type: :date)
        end
      end
    end

    let(:expected) do
      {
        type: :record,
        name: :with_date_array,
        fields: [{ name: :date_array,
                   type: { type: :array,
                           items: { type: :int, logicalType: :date } } }]
      }
    end

    it { is_expected.to be_json_eql(expected.to_json) }
  end

  context "array of logical types using #<type> method" do
    subject(:schema_json) do
      described_class.build do
        record :with_ts_array do
          required :ts_array, :array, items: long(logical_type: 'timestamp-micros')
        end
      end
    end

    let(:expected) do
      {
        type: :record,
        name: :with_ts_array,
        fields: [{ name: :ts_array,
                   type: { type: :array,
                           items: { type: :long, logicalType: 'timestamp-micros' } } }]
      }
    end

    it { is_expected.to be_json_eql(expected.to_json) }
  end
end
