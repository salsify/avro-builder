module Avro
  module Builder
    module Types

      # This concern is used by Types that can be configured using DSL
      # attributes.
      module ConfigurableType
        def configure_options(options = {})
          options.each do |key, value|
            send(key, value) if dsl_attribute?(key)
          end
        end
      end
    end
  end
end
