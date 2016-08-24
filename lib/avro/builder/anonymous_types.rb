module Avro
  module Builder

    # This concern is included by contexts where anonymous types can be defined.
    module AnonymousTypes
      include Avro::Builder::TypeFactory

      Avro::Schema::PRIMITIVE_TYPES_SYM.each do |type_name|
        define_method(type_name) do |options = {}, &block|
          type(type_name, options, &block)
        end
      end

      def union(*types, &block)
        type(__method__, { types: types }, &block)
      end

      def array(items, options = {}, &block)
        type(__method__, { items: items }.merge(options), &block)
      end

      def map(values, options = {}, &block)
        type(__method__, { values: values }.merge(options), &block)
      end

      def type(type_name, options = {}, &block)
        create_and_configure_builtin_type(type_name,
                                          cache: cache,
                                          internal: options,
                                          &block)
      end
    end
  end
end
