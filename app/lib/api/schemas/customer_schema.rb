module Api
  module Schemas
    class CustomerSchema < ::Api::BaseSchema
      define do
        required(:first_name).filled(:string).value(max_size?: 63)
        required(:last_name).filled(:string).value(max_size?: 63)
        optional(:email).maybe(:string).value(max_size?: 63, format?: Constants::EMAIL_REGEX)
        required(:mobile_number).filled(:string).value(max_size?: 63, format?: Constants::PHONE_REGEX)
        optional(:salutation).filled(:string).value(included_in?: Constants::SALUTATIONS)
      end
    end
  end
end
