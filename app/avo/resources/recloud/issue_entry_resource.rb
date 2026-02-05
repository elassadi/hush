class IssueEntryResource < ApplicationBaseResource
  include Concerns::AccountField
  include Concerns::DateResourceSidebar

  self.stimulus_controllers = %w[issue-entry-resource]

  self.title = :title
  self.authorization_policy = GlobalDataAccessPolicy
  self.includes = [:article, {
    stock_reservation: %i[purchase_order_entry purchase_order], article: %i[supplier supplier_source]
  }]
  self.translation_key = "activerecord.attributes.issue_entry"

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

  self.hide_from_global_search = true

  field :issue, as: :belongs_to, searchable: true

  field :category, as: :status_badge, options: STATUS_OPTIONS, hide_on: %i[index]
  field :category, as: :select, hide_on: %i[show index], display_with_value: true, include_blank: false,
                   options: ->(_args) { ::IssueEntry.human_enum_names(:category).invert },
                   stimulus: { action: "issue-entry-resource#onCategoryChange", view: %i[new edit] },
                   readonly: -> { view == :edit }

  field :stock_status,
        as: :status_badge, options: STOCK_OPTIONS, hide_on: %i[edit new], shorten: false,
        visible: lambda { |resource:|
                   issue = resource.record&.issue
                   next unless issue

                   !issue.status_category_done?
                 }, link_to: lambda { |resource:, model:|
                               next if model.blank?

                               if model.stock_status.to_sym == :will_be_ordered &&
                                  model.stock_reservation&.purchase_order
                                 "/resources/purchase_orders/#{model.stock_reservation.purchase_order.id}" \
                                   "?via_resource_class=IssueResource&via_resource_id=#{model.issue.id}"
                               end
                             }

  field :sku, as: :uuid, link_to_resource: false

  field :article_name, as: :text, only_on: :index, visible: ->(resource:) { resource.model.article.blank? } do
    resource.model.article_name
  end
  field :article, as: :belongs_to, only_on: :index,
                  visible: lambda { |resource:|
                             resource.model.article.present? && resource.view == :index
                           }

  field :repair_set, as: :belongs_to, searchable: true,
                     hide_on: :index, html: { edit: { wrapper: { classes: "hidden" } } },
                     stimulus: { action: "issue-entry-resource#onRepairSetChange", view: %i[new edit] },
                     attach_scope: lambda {
                                     issue = parent&.issue
                                     next query unless issue

                                     sets = RepairSet.find_sets_for_issue(issue:)
                                     next query.none if sets.empty?

                                     query.merge(
                                       RepairSet.where(id: sets.map(&:id))
                                     )
                                   }
  field :article, as: :belongs_to, hide_on: :index, searchable: true,
                  stimulus: { action: "issue-entry-resource#onArticleChange", view: %i[new edit] }

  field :article_name, as: :text, html: { edit: { wrapper: { classes: "hidden" } } }, hide_on: :index

  # rubocop:disable Rails/OutputSafety
  field :qty, as: :number, only_on: :index, as_html: true do |model|
    if model.repair_set_entry
      %{
        #{model.qty}<input type='hidden' name='row_repair_set[]'
        data-repair-set-entry-id='#{model.repair_set_entry&.id}'  data-repair-set-id='#{model.repair_set&.id}'
        data-repair-set-name='#{ActionController::Base.helpers.sanitize(model.repair_set&.name)}'
        data-repair-set-entry-price='#{(model.price * model.qty).to_brutto(round_by: 5)}'
        data-path='/repair-sets/#{model.repair_set&.id}'
      }.html_safe
    else
      model.qty
    end
  end
  # rubocop:enable Rails/OutputSafety
  field :qty, as: :number, hide_on: %i[index]
  field :price, as: :price, default: "0.0", input_mode: :brutto

  actions [DeleteAction,
           ::IssueEntries::UpdatePriceAction]
end
