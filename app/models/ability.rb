class Ability < ApplicationRecord
  include AccountOwnable

  AVAILABLE_ACTIONS = ["assign"].freeze

  belongs_to :role
  string_enum :effect, %w[allow deny], _default: :allow

  validates :action_tags, presence: true
  validates :resources, presence: true

  # validates :resource, uniqueness: { scope: %i[effect role] }

  def available_actions
    actions = ApplicationPolicy::BASIC_ACTIONS
    return actions if resources.blank?

    return actions if resources.include?("*") || resources.size > 1

    resource = resources.first
    begin
      actions + "#{resource}::AVAILABLE_ACTIONS".constantize
    rescue StandardError
      actions
    end
  end

  class << self
    def available?(role, effect:, resources:, action_tags:)
      role.abilities.where(effect:).detect do |ability|
        (resources - ability.resources).empty? &&
          (action_tags - ability.action_tags).empty?
      end
    end
  end
end
