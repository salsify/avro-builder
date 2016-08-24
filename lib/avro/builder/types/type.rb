module Avro
  module Builder
    module Types
      # Base class for simple types. The type name is specified when the
      # type is constructed. The type has no additional attributes, and
      # the type is serialized as just the type name.
      class Type
        include Avro::Builder::DslOptions
        include Avro::Builder::DslAttributes

        dsl_attribute :logical_type

        attr_reader :avro_type_name

        def initialize(avro_type_name, cache:, field: nil)
          @avro_type_name = avro_type_name
          @cache = cache
          @field = field
        end

        def serialize(_reference_state)
          if logical_type
            { type: avro_type_name, logicalType: logical_type }
          else
            avro_type_name
          end
        end

        def namespace
          nil
        end

        def configure_options(options = {})
          options.each do |key, value|
            send("#{key}=", value) if dsl_option?(key)
          end
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

        # Subclasses can override this method to indicate that the name
        # is a method that the type exposes in the DSL. These methods are in
        # addition to the methods for setting attributes on a type.
        def dsl_method?(_name)
          false
        end

        def dsl_respond_to?(name)
          dsl_attribute?(name) || dsl_method?(name)
        end

        private

        def required_attribute_error!(attribute_name)
          raise RequiredAttributeError.new(type: avro_type_name,
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

        attr_accessor :field, :cache
      end
    end
  end
end
