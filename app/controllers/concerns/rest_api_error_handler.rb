module RestApiErrorHandler
  # provides the more graceful `included` method
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound do |e|
      message = if Rails.env.development?
                  e.message
                else
                  match = e.message.match(/(Couldn't find [^\s]+) with/)
                  match.present? ? match[1] : e.message
                end

      json_response({ message: [message], status: :error }, :not_found)
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      json_response({ message: [e.message], status: :error }, :unprocessable_entity)
    end
    rescue_from ActionController::ParameterMissing do |e|
      json_response({ message: [e.message], status: :error }, :unprocessable_entity)
    end
  end
end
