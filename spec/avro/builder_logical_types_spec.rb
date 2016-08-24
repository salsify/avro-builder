describe Avro::Builder, 'logical_types' do
  let(:schema) { Avro::Schema.parse(schema_json) }

  context "primitive fields" do
    # These are the logical types supported in https://github.com/apache/avro/pull/116

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
  end

  context "fixed field" do
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

  # TODO: tests to show logical type inclusion for:
  #   record, array, map, union, bytes?, boolean?
end
