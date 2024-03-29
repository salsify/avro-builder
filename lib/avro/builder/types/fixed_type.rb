# frozen_string_literal: true

module Avro
  module Builder
    module Types
      class FixedType < NamedType

        dsl_attributes :size, :precision, :scale

        def serialize(reference_state)
          super(reference_state, overrides: serialized_attributes)
        end

        def to_h(reference_state)
          super(reference_state, overrides: serialized_attributes)
        end

        def validate!
          super
          validate_required_attribute!(:size)
        end

        private

        def serialized_attributes
          { size: size, precision: precision, scale: scale }
        end
      end
    end
  end
end
