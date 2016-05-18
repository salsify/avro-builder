module Avro
  module Builder
    module Types
      # Base class for simple types. The type name is specified when the
      # type is constructed. The type has no additional attributes, and
      # the type is serialized as just the type name.
      class Type
        include Avro::Builder::DslAttributes

        attr_reader :type_name

        def initialize(type_name, cache:, field: nil)
          @type_name = type_name
          @cache = cache
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

        # Subclasses should override this method to check for the presence
        # of required DSL attributes.
        def validate!
        end

        # Subclasses should override this method if the type definition should
        # be cached for reuse.
        def cache!
        end

        private

        def required_attribute_error!(attribute_name)
          raise RequiredAttributeError.new(type: type_name,
                                           attribute: attribute_name,
                                           field: field && field.name,
                                           name: @name)
        end

        def validate_required_attribute!(attribute_name)
          value = public_send(attribute_name)
          if value.nil? || value.respond_to?(:empty?) && value.empty?
            required_attribute_error!(attribute_name)
          end
        end

        private

        attr_accessor :field, :cache
      end
    end
  end
end
