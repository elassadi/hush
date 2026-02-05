class VersionResource < ApplicationBaseResource
  self.model_class = PaperTrail::Version

  self.title = :event
  self.includes = [:whodunnit]
  self.authorization_policy = GlobalDataAccessPolicy

  self.resolve_query_scope = lambda { |model_class:|
    model_class.order(created_at: :desc)
  }

  field :id, as: :id
  field :event, as: :text
  field :whodunnit, as: :belongs_to, polymorphic_as: :whodunnit, types: [::User]
  field :flatten_object_changes, as: :key_value, key_label: "Feld", value_label: "Alt, Neu ", stacked: true
  field :object_changes, theme: "eclipse", as: :code, language: 'javascript' do |model|
    JSON.pretty_generate(model.object_changes.as_json) if model.object_changes.present?
  end
  field_date_time :created_at, show_seconds: true
end
