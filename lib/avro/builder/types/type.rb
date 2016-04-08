module Avro
  module Builder
    module Types
      # Base class for simple types. The type name is specified when the
      # type is constructed. The type has no additional attributes, and
      # the type is serialized as just the type name.
      class Type
        include Avro::Builder::DslAttributes

        attr_reader :type_name

        def initialize(type_name, builder:, field: nil)
          @type_name = type_name
          @builder = builder
          @field = field
        end

        def serialize(_reference_state)
          type_name
        end

        def namespace
          nil
        end

        def configure_options(_options = {})
          # No-op
        end

        # Optional fields are represented as a union of the type with :null.
        def self.union_with_null(serialized)
          [:null, serialized]
        end

        private

        attr_accessor :field, :builder
      end
    end
  end
end
