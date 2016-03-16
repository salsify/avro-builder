module Avro
  module Builder

    # This class is used to keep track of references to each named type while
    # generating an Avro JSON schema. Only the first reference to the type
    # can include all of details of the definition. All subsequent references
    # must use the full name for the type.
    class SchemaSerializerReferenceState

      attr_reader :references
      private :references

      def initialize
        @references = Set.new
      end

      def definition_or_reference(fullname)
        if references.include?(fullname)
          fullname
        else
          references << fullname
          yield
        end
      end
    end
  end
end
