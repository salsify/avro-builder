module Avro
  module Builder

    # This class is used to proxy access to previously defined schema objects
    # preventing direct access via the DSL.
    class DefinitionProxy

      def initialize(builder, schema_objects)
        @builder = builder
        @schema_objects = schema_objects
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

      attr_reader :schema_objects, :builder
    end
  end
end
