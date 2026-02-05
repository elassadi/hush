module ResourcesAbilities
  class IssueAbility < BaseAbility
    attributes :user, :record

    def call
      apply
    end

    private

    def apply
      record.status_category_done?
    end
  end
end
