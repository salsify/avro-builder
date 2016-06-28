module Avro
  module Builder
    class SchemaStore
      def initialize(path: nil)
        Avro::Builder.add_load_path(path) if path
        @schemas = {}
      end

      def find(name, namespace = nil)
        fullname = Avro::Name.make_fullname(name, namespace)

        @schemas[fullname] ||= Avro::Builder.find(fullname).tap do |schema|
          if schema.respond_to?(:fullname) && schema.fullname != fullname
            raise Avro::Builder::SchemaError, "expected schema `#{name}' to define type `#{fullname}'"
          end
        end
      end
    end
  end
end
