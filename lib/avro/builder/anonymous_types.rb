module Avro
  module Builder

    # This concern is included by contexts where anonymous types can be defined.
    module AnonymousTypes
      include Avro::Builder::TypeFactory

      def union(*types, &block)
        avro_type(__method__, { types: types }, &block)
      end

      def array(items, &block)
        avro_type(__method__, { items: items }, &block)
      end

      def map(values, &block)
        avro_type(__method__, { values: values }, &block)
      end

      private

      def avro_type(type_name, options = {}, &block)
        create_and_configure_builtin_type(type_name,
                                          cache: cache,
                                          internal: options,
                                          &block)
      end
    end
  end
end
