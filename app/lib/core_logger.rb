module CoreLogger
  class << self
    def error(msg, tag: nil)
      return log_instance.error(msg) unless tag

      log_instance.tagged(tag) do
        log_instance.error(msg)
      end
    end

    def info(msg, tag: nil)
      return unless Rails.env.development?

      return log_instance.info(msg) unless tag

      log_instance.tagged(tag) do
        log_instance.info(msg)
      end
    end

    def log_instance
      @log_instance ||= begin
        path = Rails.root.join('log/debug.log')

        ActiveSupport::TaggedLogging.new(
          Logger.new(path)
        )
      end
    end
  end
end
