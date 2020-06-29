# frozen_string_literal: true

module Avro
  module Builder
    module Types
      class ArrayType < Type
        include Avro::Builder::Types::ComplexType
        include Avro::Builder::Types::TypeReferencer

        dsl_attribute :items do |items_type = nil|
          if items_type
            @items = create_builtin_or_lookup_type(items_type)
          else
            @items
          end
        end

        def validate!
          validate_required_attribute!(:items)
        end

        def serialize(referenced_state)
          super(referenced_state,
                overrides: { items: items.serialize(referenced_state) })
        end
      end
    end
  end
end
