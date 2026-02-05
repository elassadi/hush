module RecloudCore
  module Authorization
    class UnauthorizedError < StandardError; end

    class CoreAuthorizationPolicy
      def method_missing(_method, *_args)
        self
      end

      def respond_to_missing?
        true
      end

      # rubocop:disable Lint/UnusedMethodArgument
      def self.resolve(user:, model:)
        model
      end
      # rubocop:enable Lint/UnusedMethodArgument
    end

    class Client
      ACTION_PREFIXES = %w(view show attach detach create edit destroy).freeze

      def authorize(user, record, action, policy_class: nil, **args) # rubocop:todo Lint/UnusedMethodArgument
        action = action.to_s.delete("?").to_sym
        result = can?(user, action, record, **args)

        return true if result

        raise(Avo::NotAuthorizedError)
      end

      def can?(user, action, record, **_args)
        result = user.can?(action, record)
        return result if result

        # debug(result, user, record, action, args)
        # b_inding.pry
        false
        # result = compute_permissions(user, action, record, **args)
        # return result unless result.nil?

        # deny_rule_exists?(user, action, record)
      end

      def apply_policy(user, model, policy_class: nil)
        return model unless policy_class

        policy_class.resolve(user:, model:)
      end

      def policy(_user, _record)
        CoreAuthorizationPolicy.new
      end

      def policy!(_user, _record)
        CoreAuthorizationPolicy.new
      end

      private

      def debug(result, _user, record, action, args)
        class_name = record.is_a?(Class) ? record.to_s.downcase : record.class.name.downcase
        CoreLogger.info("[#{class_name}] \taction: '#{action.to_sym}' " \
                        "\tparent_action: #{args[:parent_action]} \tResult:[#{result}]")
      end
    end
  end
end
