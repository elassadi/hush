module Api
  module Schemas
    class AgentSchema < ::Api::BaseSchema
      define do
        required(:remote_agent_id).filled(:string).value(max_size?: 63)
        optional(:first_name).filled(:string).value(max_size?: 63)
        optional(:last_name).filled(:string).value(max_size?: 63)
        optional(:email).filled(:string).value(max_size?: 63, format?: Constants::EMAIL_REGEX)
        optional(:phone).filled(:string).value(max_size?: 63, format?: Constants::PHONE_REGEX)
      end
    end
  end
end
