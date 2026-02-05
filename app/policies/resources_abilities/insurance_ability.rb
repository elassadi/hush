module ResourcesAbilities
  class InsuranceAbility < BaseAbility
    attributes :user, :record

    def call
      apply
    end

    private

    def apply
      record.account_id != user.account_id
    end
  end
end
