class AbilityResource < ApplicationBaseResource
  include Concerns::DateResourceSidebar.with_fields(date_fields: %i(created_at updated_at))

  EFFECT_OPTIONS = {
    success: %w[allow],
    danger: %w[deny]
  }.freeze

  self.title = :ability
  self.stimulus_controllers = "ability-resource"
  self.includes = []

  # self.search_query = -> do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  field :id, as: :id

  field :role, as: :belongs_to
  field :effect, as: :status_badge, options: EFFECT_OPTIONS
  field :effect, as: :select, hide_on: %i[show index],
                 options: lambda { |_args|
                            ::Ability.human_enum_names(:effect, translate: false).invert
                          }, display_with_value: true

  field :resources, as: :tags, enforce_suggestions: true, close_on_select: true,
                    suggestions: lambda {
                                   ApplicationPolicy.available_resources.map do |class_name|
                                     { label: class_name, value: class_name }
                                   end
                                 }
  field :action_tags, as: :tags, enforce_suggestions: true, close_on_select: true,
                      suggestions: lambda {
                                     record.available_actions.map { |action| { label: action, value: action } }
                                   }
end
