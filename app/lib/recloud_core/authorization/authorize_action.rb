module RecloudCore
  module Authorization
    class AuthorizeAction < DryBase
      attributes :action, :subject
      optional_attributes :user, :debug

      def call
        result = user_can_perform_action_on_object?

        if result.success? && debug
          # CoreLogger.info("[#{self.class.to_s.demodulize}][#{subject_class_name}] \taction: '#{action}'  " \
          #                 "\tResult:[#{result.success}]")
        end

        result
      end

      private

      def user_can_perform_action_on_object?
        authorisation = current_user.can?(action.to_sym, subject) ? :granted : :denied

        Success({ authorisation:, cannot_rule_exists: })
      end

      def cannot_rule_exists
        cannot_permissions = current_user.ability.permissions[:cannot][action.to_sym]
        return false if cannot_permissions.blank?

        cannot_permissions.key?(subject_class_name)
      end

      def subject_class_name
        subject.is_a?(Class) ? subject.to_s : subject.class.name
      end

      def current_user
        @current_user ||= user || Current.user
      end
    end
  end
end
