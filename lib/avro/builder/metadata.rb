# frozen_string_literal: true

module Avro
  module Builder
    module Metadata
      @attribute_names = Set.new

      class << self
        def register(*attrs)
          attrs = attrs.flatten.map(&:to_sym) - attribute_names.to_a

          reserved = attrs & Avro::Builder::DslAttributes::ATTRIBUTE_NAMES
          if reserved.any?
            raise ArgumentError.new(
              "Extra metadata attribute(s) use reserved name(s): #{reserved.join(', ')}"
            )
          end

          attribute_names.merge(attrs)
        end

        def reset!
          attribute_names.clear
        end

        def attribute?(name)
          attribute_names.include?(name.to_sym)
        end

        private

        attr_reader :attribute_names
      end

      def respond_to_missing?(id, include_all)
        extra_metadata_accessor?(id) || super
      end

      def method_missing(id, *args, &block)
        if extra_metadata_accessor?(id)
          extra_metadata_access(id, args)
        else
          super
        end
      end

      private

      def extra_metadata_attribute?(name)
        Metadata.attribute?(name)
      end

      def extra_metadata
        @extra_metadata ||= {}
      end

      def extra_metadata_accessor?(name)
        name = name.to_s.delete_suffix('=').to_sym
        extra_metadata_attribute?(name)
      end

      def extra_metadata_access(name, args)
        name = name.to_s.delete_suffix('=').to_sym

        if !extra_metadata_attribute?(name)
          raise ArgumentError.new("Unknown metadata attribute: #{name}")
        elsif args.size > 1
          raise ArgumentError.new("Expected 0 or 1 arguments. Got #{args.size}")
        elsif args.empty? || args.first.nil?
          extra_metadata[name]
        else
          extra_metadata[name] = args.first
        end
      end
    end
  end
end
