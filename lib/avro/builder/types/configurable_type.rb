module Avro
  module Builder
    module Types

      # This concern is used by Types that can be configured via the DSL.
      # Only attributes that can be set via options are configured here.
      module ConfigurableType
        def configure_options(options = {})
          options.each do |key, value|
            send(key, value) if dsl_option?(key)
          end
        end
      end
    end
  end
end
