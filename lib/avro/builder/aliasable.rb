require 'avro/builder/dsl_attributes'

module Avro
  module Builder

    # This is a shared concern for objects that support aliases via the DSL.
    module Aliasable
      def self.included(base)
        base.dsl_attribute :aliases do |*names|
          if !names.empty?
            @aliases = names.flatten
          else
            @aliases
          end
        end
      end
    end

  end
end
