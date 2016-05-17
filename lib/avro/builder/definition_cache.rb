module Avro
  module Builder

    # This class is used to cache previously defined schema objects
    # preventing direct access via the DSL.
    class DefinitionCache
      def initialize(builder)
        @builder = builder
        @schema_objects = {}
      end

      def add_schema_object(object)
        store_if_new(object.fullname, object)
      end

      # Lookup an Avro schema object by name, possibly fully qualified by namespace.
      def lookup_named_type(key, namespace = nil)
        key_str = Avro::Name.make_fullname(key.to_s, namespace)
        object = schema_objects[key_str]

        unless object
          builder.import(key)
          object = schema_objects[key_str]
        end

        raise "Schema object #{key} not found" unless object
        object
      end

      private

      def store_if_new(key, object)
        raise DuplicateDefinitionError.new(key, object, schema_objects[key]) if schema_objects.key?(key)
        schema_objects.store(key, object)
      end

      attr_reader :schema_objects, :builder
    end
  end
end
