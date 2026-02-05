class DeviceManufacturerResource < ApplicationBaseResource
  include Concerns::ResourcesDefaultSetting.with_options
  include Concerns::AccountField
  include Concerns::DateResourceSidebar

  self.authorization_policy = SharedDataAccessPolicy

  self.title = :name

  self.includes = [:device_models]

  self.resolve_query_scope = lambda { |model_class:|
    model_class.order(name: :asc)
  }

  self.hide_from_global_search = true
  self.search_query = lambda {
    scope.ransack(name_matches: "%#{params[:q]}%", m: "or").result(distinct: false)
  }

  field :name, as: :text

  field :device_models, as: :has_many, modal_create: true

  filters [
    Devices::NameFilter,
    ByAccountFilter
  ]
end
