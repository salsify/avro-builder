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
        store_if_new(object.fullname, object) if object.namespace
        store_if_new(object.name.to_s, object)
      end

      # Lookup an Avro schema object by name, possibly fully qualified by namespace.
      def lookup_named_type(key)
        key_str = key.to_s
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
