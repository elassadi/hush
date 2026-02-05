class ErrorTracking
  class << self
    include Dry::Monads[:result, :do]

    def capture_message(msg, level: :error, **opts)
      Sentry.capture_message(msg, level:, **opts)
      Rails.logger.error(msg)
      # if Rails.env.test?
      #   puts "****************** ERROR Captured **************************"
      #   puts msg
      #   puts "************************************************************"
      # end
    end

    def capture_error(exception, level: :error, **opts)
      Sentry.capture_exception(exception, level:, **opts)
    end
  end
end
