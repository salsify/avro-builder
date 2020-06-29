# frozen_string_literal: true

module Avro
  module Builder
    module Types
      class MapType < Type
        include Avro::Builder::Types::ComplexType
        include Avro::Builder::Types::TypeReferencer

        dsl_attribute :values do |value_type = nil|
          if value_type
            @values = create_builtin_or_lookup_type(value_type)
          else
            @values
          end
        end

        def serialize(referenced_state)
          super(referenced_state,
                overrides: { values: values.serialize(referenced_state) })
        end

        def validate!
          validate_required_attribute!(:values)
        end
      end
    end
  end
end
