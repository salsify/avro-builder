# frozen_string_literal: true

record :invalid do
  required :i, :int do
    # call a method that does not exist
    does_not_exist :foo
  end
end
