class SequenceResource < ApplicationBaseResource
  self.includes = []
  self.authorization_policy = GlobalDataAccessPolicy
  self.model_class = Sequence
  self.translation_key = "activerecord.attributes.sequence"

  field :setting, as: :belongs_to, readonly: lambda {
                                               record.persisted?
                                             }

  field :heading, as: :heading_help, i18n_key: :heading_sequences, path: "/global_settings/sequences"
  field :sequenceable_type, as: :select,
                            options: lambda { |_args|
                                       ::Sequence.human_enum_names(:sequenceable_type, translate: true).invert
                                     }, display_with_value: true, include_blank: true

  field_date :active_since, default: -> { Time.zone.now.to_date }, picker_options: {
    minDate: Time.zone.now.to_date
  }, help: I18n.t('helpers.sequence.active_since')

  field :counter_start, as: :number, help: I18n.t('helpers.sequence.counter_start')
  # docs_link(path: '/import-into-catalogue.html', i18n_key: :help_message)
end
