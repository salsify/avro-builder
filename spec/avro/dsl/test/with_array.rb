# frozen_string_literal: true

record :with_array, namespace: :test do
  required :array_of_ints, :array, items: :int
end
