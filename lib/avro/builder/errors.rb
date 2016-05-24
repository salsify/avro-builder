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

    class DuplicateDefinitionError < StandardError
      def initialize(key, object, existing_object)
        super("definition for #{key.inspect} already exists\n"\
              "existing definition:\n#{to_json(existing_object)}\n"\
              "new definition:\n#{to_json(object)})")
      end

      private

      def to_json(object)
        object.to_h(SchemaSerializerReferenceState.new).to_json
      end
    end

    class DefinitionNotFoundError < StandardError
      def initialize(name)
        super("definition not found for '#{name}'.#{suggest_namespace(name)}")
      end

      private

      def suggest_namespace(name)
        ' Try specifying the full namespace.' unless name.to_s.index('.')
      end
    end

    class UnsupportedBlockAttributeError < StandardError
      def initialize(attribute:, type:, field: nil)
        target = if field
                   "field '#{field}' of type :#{type}"
                 else
                   "type :#{type}"
                 end
        super("'#{attribute}' must be set directly using an option on #{target}")
      end
    end
  end
end
