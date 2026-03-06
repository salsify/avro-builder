# frozen_string_literal: true

module Avro
  module Builder
    module Types
      # Subclass of Type for primitive Avro types (null, boolean, int, long,
      # float, double, bytes, string).
      class PrimitiveType < Type
        def serialize(reference_state)
          if logical_type
            super
          else
            avro_type_name
          end
        end
      end
    end
  end
end
