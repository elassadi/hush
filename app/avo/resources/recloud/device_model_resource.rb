class DeviceModelResource < ApplicationBaseResource
  include Concerns::ResourcesDefaultSetting.with_options
  include Concerns::AccountField
  include Concerns::DateResourceSidebar

  self.authorization_policy = SharedDataAccessPolicy
  STATUS_OPTIONS = {
    gray: %w[disabled],
    info: %w[],
    success: %w[active],
    warning: %w[],
    danger: %w[deleted]
  }.freeze

  self.title = :name
  self.includes = %i[device_colors device_manufacturer]

  self.resolve_query_scope = lambda { |model_class:|
    model_class.order(name: :asc)
  }

  self.hide_from_global_search = true
  self.search_query = lambda {
    scope.ransack(name_matches: "%#{params[:q]}%", m: "or").result(distinct: false)
  }

  field :device_manufacturer, as: :belongs_to
  field :status, as: :status_badge, options: STATUS_OPTIONS
  field :name, as: :text
  field :status, as: :select, hide_on: %i[show index],
                 options: lambda { |_args|
                            ::Supplier.human_enum_names(:status, translate: true, reject: :deleted).invert
                          }, display_with_value: true, include_blank: false
  field :device_model_category, as: :belongs_to, in_line: :create

  field :image, as: :file, hide_on: :index,
                visible: ->(resource:) { resource.model.image.present? || resource.view == :edit },
                html: { show: { wrapper: { style: "max-width: 300px;" } } }

  field :gsm_path, as: :text, as_html: true, hide_on: :index,
                   visible: ->(resource:) { resource.model.image.blank? } do |record, _resource, _view|
    %{<img src="#{record.gsm_path}" alt="#{record.name}" style="max-width: 300px;margin: auto;">}
  end

  field :device_colors, as: :has_many, modal_create: true
  field :repair_sets, as: :has_many
  field :devices, as: :has_many

  filters [
    DeviceModels::NameFilter,
    ByAccountFilter
  ]
  actions [DeviceModels::DisableAction, DeviceModels::ActivateAction]
end
