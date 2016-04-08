module Avro
  module Builder
    module Types
      class UnionType < Type
        include Avro::Builder::Types::ComplexType
        include Avro::Builder::Types::ConfigurableType
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
          types.map { |type| type.serialize(referenced_state) }
        end

        # serialized will be an array of types. If the array includes
        # :null then it is moved to the beginning of the array.
        def self.union_with_null(serialized)
          serialized.reject { |type| type.to_s == NULL_TYPE }.unshift(:null)
        end
      end
    end
  end
end
