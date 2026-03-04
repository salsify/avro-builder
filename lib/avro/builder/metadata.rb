# frozen_string_literal: true

module Avro
  module Builder
    module Metadata
      module ClassMethods
        def extra_metadata_attributes(attrs)
          conflicting = attrs.select do |attr|
            dsl_attribute_names.include?(attr.to_sym) && !extra_metadata_attribute_names.include?(attr.to_sym)
          end
          if conflicting.any?
            raise ArgumentError.new(
              "Extra metadata attribute(s) conflict with existing attribute(s): #{conflicting.join(', ')}"
            )
          end

          new_attrs = attrs.reject { |attr| extra_metadata_attribute_names.include?(attr.to_sym) }
          extra_metadata_attribute_names.merge(new_attrs.map(&:to_sym))
          dsl_attributes(*new_attrs) unless new_attrs.empty?
        end

        def extra_metadata_attribute_names
          @extra_metadata_attribute_names ||= Set.new
        end
      end

      def self.included(base)
        base.extend ClassMethods
      end

      private

      def extra_metadata_hash
        self.class.extra_metadata_attribute_names.each_with_object({}) do |attr, hash|
          value = send(attr)
          hash[attr] = value unless value.nil?
        end
      end
    end
  end
end
