module Avro
  module Builder

    # This class is used to cache previously defined schema objects
    # preventing direct access via the DSL.
    class DefinitionCache
      def initialize(builder)
        @builder = builder
        @schema_objects = {}
        @schema_names = Set.new
      end

      # Cache and schema object by name (for convenience) and fullname.
      # The schema object is only available by name if the unqualified name is unique.
      def add_schema_object(object)
        store_by_name(object) if object.namespace
        store_by_fullname(object)
      end

      # Lookup an Avro schema object by name, possibly fully qualified by namespace.
      def lookup_named_type(key, namespace = nil)
        key_str = Avro::Name.make_fullname(key.to_s, namespace && namespace.to_s)
        object = schema_objects[key_str]

        unless object || schema_names.include?(key.to_s)
          object = builder.import(key)
        end

        raise DefinitionNotFoundError.new(key) unless object
        object
      rescue DefinitionNotFoundError
        if namespace
          lookup_named_type(key, nil)
        else
          raise
        end
      end

      private

      # Schemas are stored by name, provided that the name is unique.
      # If the unqualified name is ambiguous then it is removed from the cache.
      # A set of unqualified names is kept to avoid reloading files for
      # ambiguous references.
      def store_by_name(object)
        key = object.name.to_s
        schema_names.add(key)
        if schema_objects.key?(key)
          schema_objects.delete(key)
        else
          schema_objects.store(key, object)
        end
      end

      def store_by_fullname(object)
        key = object.fullname
        raise DuplicateDefinitionError.new(key, object, schema_objects[key]) if schema_objects.key?(key)
        schema_objects.store(key, object)
      end

      attr_reader :schema_objects, :schema_names, :builder
    end
  end
end
