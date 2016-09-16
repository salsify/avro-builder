describe Avro::Builder, 'type_macros' do
  context "without a type object" do
    let(:schema_json) do
      described_class.build do
        type_macro :num, :int
      end
    end
    it "raises an error" do
      expect { schema_json }.to raise_error(':int must be a type object')
    end
  end

  context "macro defined locally" do
    subject(:schema_json) do
      described_class.build do
        type_macro :timestamp, long(logical_type: 'timestamp-millis')

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

    context "with namespace included" do
      let(:expected) do
        {
          type: :record,
          name: :system,
          namespace: :X,
          fields: [
            { name: :user_ids, type: { type: :array, items: :int } },
            { name: :group_ids, type: { type: :array, items: :int } }
          ]
        }
      end
      context "namespace in options" do
        subject(:schema_json) do
          described_class.build do
            type_macro :id_array, array(int), namespace: 'test.foo'

            record :system, namespace: :X do
              required :user_ids, :id_array
              required :group_ids, 'test.foo.id_array'
            end
          end
        end
        it { is_expected.to be_json_eql(expected.to_json) }
      end

      context "namespace via context" do
        subject(:schema_json) do
          described_class.build do
            namespace 'test.foo'
            type_macro :id_array, array(int)

            record :system, namespace: :X do
              required :user_ids, :id_array
              required :group_ids, 'test.foo.id_array'
            end
          end
        end
        it { is_expected.to be_json_eql(expected.to_json) }
      end

      context "namespace included in name" do
        subject(:schema_json) do
          described_class.build do
            type_macro 'test.foo.id_array', array(int)

            record :system do
              required :user_ids, :id_array
              required :group_ids, 'test.foo.id_array'
            end
          end
        end
        it "raises an error" do
          expect { schema_json }
            .to raise_error('namespace cannot be included in name: test.foo.id_array')
        end
      end
    end
  end

  context "type macro from a file" do
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

    context "with namespace specified for type macro" do
      subject(:schema_json) do
        described_class.build do
          record :with_date do
            required :d, 'test.date'
          end
        end
      end
      it { is_expected.to be_json_eql(expected.to_json) }
    end
  end
end
