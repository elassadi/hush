module Api
  module Schemas
    class AddressSchema < ::Api::BaseSchema
      define do
        required(:street).filled(:string).value(max_size?: 63)
        required(:house_number).filled(:string).value(max_size?: 20)
        required(:post_code).filled(:string).value(size?: 5, format?: Constants::CITY_CODE_REGEX)
        required(:city).filled(:string).value(max_size?: 63)
      end
    end
  end
end
