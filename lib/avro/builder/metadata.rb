# frozen_string_literal: true

module Avro
  module Builder
    module Metadata
      module ClassMethods
        def extra_metadata_attributes(attrs)
          conflicting = attrs.select do |attr|
            dsl_attribute_names.include?(attr.to_sym) && !extra_metadata_attribute?(attr.to_sym)
          end
          if conflicting.any?
            raise ArgumentError.new(
              "Extra metadata attribute(s) conflict with existing attribute(s): #{conflicting.join(', ')}"
            )
          end

          new_attrs = attrs.reject { |attr| extra_metadata_attribute?(attr.to_sym) }
          unless new_attrs.empty?
            own_extra_metadata_attribute_names.merge(new_attrs.map(&:to_sym))
            dsl_attributes(*new_attrs)
          end
        end

        def extra_metadata_attribute?(name)
          if own_extra_metadata_attribute_names.include?(name.to_sym)
            true
          elsif superclass.respond_to?(:extra_metadata_attribute?)
            superclass.extra_metadata_attribute?(name)
          else
            false
          end
        end

        def extra_metadata_attribute_names
          if superclass.respond_to?(:extra_metadata_attribute_names)
            superclass.extra_metadata_attribute_names.dup.merge(own_extra_metadata_attribute_names).freeze
          else
            own_extra_metadata_attribute_names.dup.freeze
          end
        end

        private

        def own_extra_metadata_attribute_names
          @own_extra_metadata_attribute_names ||= Set.new
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
