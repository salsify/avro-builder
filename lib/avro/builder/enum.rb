module Avro
  module Builder

    class Enum < Avro::Builder::Types::EnumType
      include Avro::Builder::Types::TopLevel
    end
  end
end
