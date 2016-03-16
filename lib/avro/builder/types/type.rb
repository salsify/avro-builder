module Avro
  module Builder
    module Types
      # Base class for simple types. The type name is specified when the
      # type is constructed. The type has no additional attributes, and
      # the type is serialized as just the type name.
      class Type
        include Avro::Builder::DslAttributes

        attr_reader :type_name
        attr_accessor :field, :builder

        def initialize(type_name)
          @type_name = type_name
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
      end
    end
  end
end
