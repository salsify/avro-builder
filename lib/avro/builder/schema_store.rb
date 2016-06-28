module Avro
  module Builder
    # This class implements a schema store that loads Avro::Builder
    # DSL files and returns Avro::Schema objects.
    # It implements the same API as AvroTurf::SchemaStore.
    class SchemaStore
      def initialize(path: nil)
        Avro::Builder.add_load_path(path) if path
        @schemas = {}
      end

      def find(name, namespace = nil)
        fullname = Avro::Name.make_fullname(name, namespace)

        @schemas[fullname] ||= Avro::Builder::DSL.new { eval_file(fullname) }
          .as_schema.tap do |schema|
            if schema.respond_to?(:fullname) && schema.fullname != fullname
              raise SchemaError.new(schema.fullname, fullname)
            end
          end
      end
    end
  end
end
