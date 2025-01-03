# frozen_string_literal: true

module Avro
  module Builder
    module Metadata
      module ClassMethods
        def extra_metadata_attributes(attrs)
          dsl_attributes *attrs
        end
      end

      def self.included(base)
        base.extend ClassMethods
      end
    end
  end
end
