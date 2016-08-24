module Avro
  module Builder
    module Types
      class UnionType < Type
        include Avro::Builder::Types::ComplexType
        include Avro::Builder::Types::TypeReferencer

        NULL_TYPE = 'null'.freeze

        dsl_attribute :types do |*types|
          if !types.empty?
            @types = types.flatten.map { |type| create_builtin_or_lookup_named_type(type) }
          else
            @types
          end
        end

        # Unions are serialized as an array of types
        def serialize(referenced_state)
          types_array = types.map { |type| type.serialize(referenced_state) }
          if logical_type
            { type: types_array, logicalType: logical_type }
          else
            types_array
          end
        end

        # serialized will be an array of types. If the array includes
        # :null then it is moved to the beginning of the array.
        def self.union_with_null(serialized)
          serialized.reject { |type| type.to_s == NULL_TYPE }.unshift(:null)
        end

        def validate!
          validate_required_attribute!(:types)
        end
      end
    end
  end
end
