module Avro
  module Builder

    class Record < Avro::Builder::Types::RecordType
      include Avro::Builder::Types::TopLevel

      # This was copy-pasted; it's meant to be a proof-of-concept, not actually shippable code
      def record(name = nil, options = {}, &block)
        create_and_configure_builtin_type(
          :record,
          cache: cache,
          internal: { _name: name, namespace: namespace },
          options: options,
          &block
        )
      end
    end
  end
end
