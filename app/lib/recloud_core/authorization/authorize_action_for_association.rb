module RecloudCore
  module Authorization
    class AuthorizeActionForAssociation < DryBase
      ACTION_PREFIXES = %w[view create update destroy].freeze
      attributes :action, :subject
      optional_attributes :user, :debug, :model

      def call
        result = user_can_perform_action_on_association?

        if result.success? && debug
          # CoreLogger.info("[#{self.class.to_s.demodulize}][#{subject_class_name}] \taction: '#{action}'" \
          #                 "\tassociation_action: '#{association_action}'   \tResult:[#{result.success}]")
        end

        result
      end

      private

      def user_can_perform_action_on_association?
        # b_inding.pry if action.to_s =="destroy_issue_entries"
        authorisation = :not_defined

        if association_action && association_klass
          object_to_check = model.is_a?(association_klass) ? model : association_klass
          authorisation = current_user.can?(association_action, object_to_check) ? :granted : :not_defined
        end

        if cannot_rule_exists
          authorisation = current_user.can?(action, subject) ? :granted : :denied
        end
        Success({ authorisation:, cannot_rule_exists: })
      end

      def cannot_rule_exists
        @cannot_rule_exists ||= begin
          cannot_permissions = current_user.ability.permissions[:cannot][action]
          cannot_permissions.key?(subject_class_name) if cannot_permissions.present?
        end
      end

      def subject_class_name
        subject.is_a?(Class) ? subject.to_s : subject.class.name
      end

      def current_user
        @current_user ||= user || Current.user
      end

      def association_klass
        @association_klass ||= begin
          subject.class.reflect_on_association(association).class_name.constantize if association
        rescue NameError
          nil
        end
      end

      def association
        split_and_detect_association_action.present? && split_and_detect_association_action.second
      end

      def association_action
        split_and_detect_association_action.present? && split_and_detect_association_action.first.to_sym
      end

      def split_and_detect_association_action
        prefix = ACTION_PREFIXES.detect do |p|
          action.start_with?(p)
        end
        return unless prefix

        [prefix, action.to_s.split("#{prefix}_", 2).second]
      end
    end
  end
end
