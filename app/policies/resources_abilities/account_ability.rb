module ResourcesAbilities
  class AccountAbility < BaseAbility
    attributes :user, :record, :args

    def call
      apply
    end

    private

    def apply
      if args[:action] == :create
        return true
      end
      return true unless record.respond_to?(:account_id)
      return true unless record.persisted?

      return true if user.access_level_global?

      action = args[:action]
      record.account_id == user.current_account.id || shared_read_access?(action, record)
    end

    def shared_read_access?(action, record)
      action.to_sym == :read && Constants::SHARED_DATA_MODELS.include?(record.class) &&
        record.account_id == recloud_id
    end

    def recloud_id
      @recloud_id ||= ::Account.recloud.id
    end
  end
end
