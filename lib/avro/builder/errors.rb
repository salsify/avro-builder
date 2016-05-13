module Avro
  module Builder

    class RequiredAttributeError < StandardError
      def initialize(type:, attribute:, field: nil, name: nil)
        location = if field
                     "field '#{field}' of "
                   elsif name
                     "'#{name}' of "
                   end
        super("attribute :#{attribute} missing for #{location}type :#{type}")
      end
    end
  end
end
