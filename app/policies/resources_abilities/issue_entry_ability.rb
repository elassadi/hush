module ResourcesAbilities
  class IssueEntryAbility < BaseAbility
    attributes :user, :record

    def call
      apply
    end

    private

    def apply
      if record.is_a?(IssueEntry)
        record.issue.status_category_done?
      else
        record.status_category_done?
      end
    end
  end
end
