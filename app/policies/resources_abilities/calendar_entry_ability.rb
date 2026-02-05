module ResourcesAbilities
  class CalendarEntryAbility < BaseAbility
    attributes :user, :record

    def call
      apply
    end

    private

    def apply
      if record.entry_type.in?(%w[blocker user])
        false
      else
        !record.status_canceld?
      end
    end
  end
end
