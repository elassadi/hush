class DeviceColorResource < ApplicationBaseResource
  include Concerns::ResourcesDefaultSetting.with_options
  include Concerns::AccountField
  include Concerns::DateResourceSidebar

  self.authorization_policy = SharedDataAccessPolicy

  self.title = :name
  self.includes = [:device_model]

  self.resolve_query_scope = lambda { |model_class:|
    model_class.order(name: :asc)
  }

  field :device_model, as: :belongs_to, searchable: true
  field :name, as: :text

  filter Devices::NameFilter

  action DummyAction
end
