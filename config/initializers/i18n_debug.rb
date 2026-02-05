# config/initializers/i18n_debug.rb

if Rails.env.development?
  module I18n
    class << self
      alias_method :original_translate, :translate

      def translate(key, options = {})
        # Log or debug the translation key and options
        #CoreLogger.info "I18n Key: #{key}, Options: #{options.inspect}"

        #r = original_translate(key, **options)
        #CoreLogger.info "I18n Key: #{key}, Options: #{options.inspect}, result: #{r.inspect}"
        #r
        original_translate(key, **options)
      end

      alias_method :t, :translate # Ensure `I18n.t` calls this new method
    end
  end
end
