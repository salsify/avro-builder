describe Avro::Builder, 'user_defined_types' do
  context "user-defined type defined locally" do
    subject(:schema_json) do
      described_class.build do
        define_type(:timestamp, long(logical_type: 'timestamp-millis'))

        record :user do
          required :created_at, :timestamp
          required :updated_at, :timestamp
        end
      end
    end
    let(:expected) do
      {
        type: :record,
        name: :user,
        fields: [
          { name: :created_at, type: { type: :long, logicalType: 'timestamp-millis' } },
          { name: :updated_at, type: { type: :long, logicalType: 'timestamp-millis' } }
        ]
      }
    end
    it { is_expected.to be_json_eql(expected.to_json) }
  end

  context "user defined type from a file" do
    subject(:schema_json) do
      described_class.build do
        record :with_date do
          required :d, :date
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
  end
end
