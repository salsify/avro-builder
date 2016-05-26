module Avro
  module Builder

    class Fixed < Avro::Builder::Types::FixedType
      include Avro::Builder::Types::TopLevel
    end
  end
end
