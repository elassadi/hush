module ResourcesAbilities
  class UserAbility < BaseAbility
    attributes :user, :record, :action, :effect

    def call
      apply
    end

    private

    def apply

      return destroy_ability if action == :destroy
      return edit_ability if action == :edit
    end

    def destroy_ability
      return true if effect != :cannot

      return false if user.access_level_global?

      if user.account_admin?
        return false if user.account_id == record.account_id && user.id != record.id
      end

      true
    end

    def edit_ability
      return true if user.access_level_global?

      if user.account_admin?
        return true if user.account_id == record.account_id
      end

      user.id == record.id
    end
  end
end
