module Avro
  module Builder

    # This concern is used to generate the full name for objects that may
    # be namespaced.
    module Namespaceable
      def fullname
        [namespace, name].compact.join('.')
      end
    end
  end
end
