class RepairSetResource < ApplicationBaseResource
  include Concerns::ResourcesDefaultSetting.with_options(show_uuid: :show)
  include Concerns::AccountField
  include Concerns::DateResourceSidebar

  STATUS_OPTIONS = {
    gray: %w[unknown],
    info: %w[],
    success: %w[paid],
    warning: %w[refunded],
    danger: %w[unknown]
  }.freeze

  STOCK_OPTIONS = {
    gray: %w[shortly_available],
    info: %w[ordered delivered],
    success: %w[available],
    warning: %w[reserved will_be_ordered can_be_ordered upon_order],
    danger: %w[unavailable unknown]
  }.freeze

  self.search_query = lambda {
    ResourceHelpers::SearchEngine.call(search_query: params[:q],
                                       global: params[:global].to_boolean, scope:, model: :repair_set).success
  }

  self.resolve_query_scope = lambda { |model_class:|
    model_class.order(name: :asc)
  }

  self.includes = %i[device_model device_failure_category repair_set_entries]
  self.stimulus_controllers = "repair-set-resource entries-summary-tool"
  self.title = :name

  self.show_controls = lambda {
    back_button
    delete_button
    actions_list
    link_to "+ #{I18n.t('activerecord.attributes.issue.new_issue')}",
            "/resources/issues/new?via_repair_set_id=#{params[:id]}",
            style: :primary, color: :primary
    edit_button
  }

  field :search_set_name, as: :text, hide_on: :all, as_label: true do |model|
    model.name_with_price_and_stock_status
  end

  field :base_data_heading, as: :heading
  field :stock_status, as: :status_badge, options: STOCK_OPTIONS,
                       hide_on: %i[edit new], shorten: false
  field :name, as: :text
  field :autogenerate_name, as: :boolean, only_on: :new
  field :description, as: :textarea

  field :device_heading, as: :heading

  field :device_model, as: :belongs_to, searchable: true, in_line: :create,
                       stimulus: { action: "repair-set-resource#onDeviceModelChange", view: %i[new edit] }
  field :device_color, as: :belongs_to, nullable: true,
                       null_values: ['0', nil], attach_scope: lambda {
                                                                if parent && parent.device_model_id
                                                                  query.where(device_model_id: parent.device_model_id)
                                                                else
                                                                  query.none
                                                                end
                                                              }, hide_on: :index

  field :device_failure_category_heading, as: :heading
  field :device_failure_category, as: :belongs_to
  field :repair_set_entries, as: :has_many, modal_create: true
  field :raw_retail_price, as: :price, only_on: [:show], input_mode: :brutto
  field :price, as: :price, hide_on: :forms, input_mode: :brutto

  field :via_cloned_id, as: :hidden, default: -> { params[:via_cloned_id].presence || false }

  tool EntriesSummaryTool
  filter RepairSets::NameFilter
  actions(::CloneAction, ::DeleteAction)
end
