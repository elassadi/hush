module ResourcesAbilities
  class BusinessHourAbility < BaseAbility
    attributes :user, :record

    def call
      apply
    end

    private

    def apply
      BusinessHour.generate_day_options(record).blank?
    end
  end
end
