class AvoAuthorizationClient
  class UnauthorizedError < StandardError; end
  ACTION_PREFIXES = %w(view show attach detach create edit destroy).freeze

  def authorize(user, record, action, policy_class: nil, **args) # rubocop:todo Lint/UnusedMethodArgument
    raise(UnauthorizedError) unless Authorization::Client.can?(user, sanitize_action(action), record, **args)
  end

  def sanitize_action(action)
    action.to_s.delete("?")
  end

  def policy(_user, _record)
    CoreAuthorizationPolicy.new
  end

  def policy!(_user, _record)
    CoreAuthorizationPolicy.new
  end

  def apply_policy(user, model, policy_class: nil)
    return model unless policy_class

    policy_class.resolve(user:, model:)
  end

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
end
