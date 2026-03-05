# frozen_string_literal: true

module Avro
  module Builder
    module Types
      class EnumType < NamedType

        dsl_attributes :doc, :default

        dsl_attribute :symbols do |*values|
          # Define symbols explicitly to support values as a splat or single array
          if !values.empty?
            @symbols = values.flatten
          else
            @symbols
          end
        end

        def validate!
          super
          validate_required_attribute!(:symbols)
          validate_enum_default!
        end

        private

        def validate_enum_default!
          if !default.nil? && !symbols.map(&:to_sym).include?(default.to_sym)
            raise AttributeError.new("enum default '#{default}' must be one of the enum symbols: #{symbols}")
          end
        end

        def serialized_attribute_hash(_reference_state)
          super.merge(symbols: symbols, doc: doc, default: default)
        end
      end
    end
  end
end
