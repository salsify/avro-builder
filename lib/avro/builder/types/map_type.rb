module Avro
  module Builder
    module Types
      class MapType < Type
        include Avro::Builder::Types::ComplexType
        include Avro::Builder::Types::ConfigurableType
        include Avro::Builder::Types::TypeReferencer

        dsl_attribute :values do |value_type = nil|
          if value_type
            @values = create_builtin_or_lookup_named_type(value_type)
          else
            @values
          end
        end

        def serialize(referenced_state)
          {
            type: type_name,
            values: values.serialize(referenced_state)
          }
        end
      end
    end
  end
end
