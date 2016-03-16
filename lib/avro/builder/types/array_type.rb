require 'avro/builder/types/configurable_type'
require 'avro/builder/types/type_referencer'

module Avro
  module Builder
    module Types
      class ArrayType < Type
        include Avro::Builder::Types::SpecificType
        include Avro::Builder::Types::ConfigurableType
        include Avro::Builder::Types::TypeReferencer

        dsl_attribute :items do |items_type = nil|
          if items_type
            @items = find_or_create_type(items_type)
          else
            @items
          end
        end

        def serialize(referenced_state)
          {
            type: type_name,
            items: items.serialize(referenced_state)
          }
        end
      end
    end
  end
end
