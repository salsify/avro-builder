# frozen_string_literal: true

module Avro
  module Builder
    module Types
      class FixedType < NamedType

        dsl_attributes :size, :precision, :scale

        def validate!
          super
          validate_required_attribute!(:size)
        end

        private

        def serialized_attribute_hash(_reference_state)
          super.merge(size: size, precision: precision, scale: scale)
        end
      end
    end
  end
end
