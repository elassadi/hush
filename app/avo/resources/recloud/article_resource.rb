class ArticleResource < ApplicationBaseResource
  include Concerns::AccountField
  # include Concerns::DateResourceSidebar.with_fields(date_fields: %i(created_at updated_at))

  ALL_OPTIONS = {
    gray: %w[stueck basic disabled],
    info: %w[],
    success: %w[active absolut],
    warning: %w[service freight percentage],
    danger: %w[disabled deleted]
  }.freeze

  self.title = :title
  self.includes = %i[account article_group stock supplier_source supplier]
  self.stimulus_controllers = ["article-resource"]
  self.authorization_policy = GlobalDataAccessPolicy
  self.translation_key = "activerecord.attributes.article"
  self.hide_from_global_search = true
  self.search_query = lambda {
    ResourceHelpers::SearchEngine.call(search_query: params[:q], global: params[:global].to_boolean, scope:,
                                       model: :article).success
  }

  self.show_controls = lambda {
    back_button
    delete_button if current_user.can?(:edit, record)

    actions_list

    action Articles::MarkAsInventoriedAction, style: :primary, color: :green, icon: "heroicons/solid/check", label: "",
                                              title: I18n.t("actions.articles.mark_as_inventoried_action.message")
    link_to "",
            "/resources/stock_movements/new?modal_resource=modal_resource&via_child_resource=StockMovementResource" \
            "&via_relation=article&via_relation_class=Article&stock_out=true&via_resource_id=#{params[:id]}",
            icon: "heroicons/outline/arrow-up-tray",
            title: I18n.t('activerecord.attributes.stock_movement.actions.stock_out'),
            style: :text,
            color: :red,
            form_class: 'flex flex-col sm:flex-row sm:inline-flex',
            data: { turbo_frame: "modal_resource" }
    link_to "",
            "/resources/stock_movements/new?modal_resource=modal_resource&via_child_resource=StockMovementResource" \
            "&via_relation=article&via_relation_class=Article&via_resource_id=#{params[:id]}",
            icon: "heroicons/outline/arrow-down-tray",
            title: I18n.t('activerecord.attributes.stock_movement.actions.stock_in'),
            style: :primary, color: :primary,
            data: { turbo_frame: "modal_resource" }
    edit_button if current_user.can?(:edit, record)
  }

  # field :status, as: :status_badge, options: ALL_OPTIONS
  #field :sku, as: :uuid, shorten: false, link_to_resource: false
  field :name, as: :heading, name: :heading_name
  field :title, as: :text, only_on: :index, link_to_resource: true
  field :name, as: :text, hide_on: :index
  field :name_en, as: :text, hide_on: :index, nullable: true
  field :article_group, as: :belongs_to, attach_scope: -> { query.by_account }, hide_on: :index, in_line: :create
  field :article_type, as: :status_badge, options: ALL_OPTIONS
  field :article_type, as: :select, hide_on: %i[show index],
                       options: ->(_args) { ::Article.human_enum_names(:article_type, translate: false).invert },
                       stimulus: { action: "article-resource#onArticleTypeChange", view: %i[new edit] },
                       display_with_value: true, include_blank: false
  field :description, as: :textarea
  field :ean, as: :text, hide_on: :index, nullable: true
  field :sku, as: :text, hide_on: :index, nullable: true
  field :tax, as: :number, default: 19.0, hide_on: :index

  field :details, as: :heading, name: :heading_details

  # field :supplier, as: :belongs_to, attach_scope: -> { query.by_account }, hide_on: :index, in_line: :create

  field :unit, as: :status_badge, options: ALL_OPTIONS, hide_on: :index
  field :unit, as: :select, hide_on: %i[show index],
               options: ->(_args) { ::Article.human_enum_names(:unit).invert }, display_with_value: true,
               include_blank: false

  # field :in_stock_available,
  #       as: :text,
  #       sortable: lambda { |query, direction|
  #                   query.except(:includes, :supplier_source).joins(:stock)
  #                        .order("stocks.in_stock_available #{direction}")
  #                 } do |model|
  #   model.stock&.in_stock_available
  # end

  field :supplier, as: :belongs_to, attach_scope: -> { query.by_account },
                   in_line: :create, hide_on: %i[index forms]

  field :pricing, as: :heading_help, i18n_key: :heading_pricing_strategie, path: "/articles/article"

  field :pricing_strategie, as: :status_badge, options: ALL_OPTIONS, hide_on: :index
  field :pricing_strategie, as: :select, hide_on: %i[show index],
                            options: ->(_args) { ::Article.human_enum_names(:pricing_strategie).invert },
                            stimulus: { action: "article-resource#onPricingStrategieChange", view: %i[new edit] },
                            display_with_value: true, include_blank: false

  field(
    :default_purchase_price,
    as: :price, tax: AppConfig::GLOBAL_TAX, only_on: :forms,
    readonly: -> { resource.model && resource.model.supplier },
    stimulus: { action: "article-resource#onDefaultPurchasePriceChanged", view: %i[new edit] }
  )

  #field :purchase_price, as: :price, only_on: :show
  field :min_preis, as: :price, only_on: [:show, :index] , tax: AppConfig::GLOBAL_TAX, input_mode: :brutto
  field :default_retail_price, as: :price, only_on: :show, tax: AppConfig::GLOBAL_TAX, input_mode: :brutto


  field :margin, as: :price, as_percent: true, help: I18n.t('helpers.article.margin'), only_on: :forms,
                 stimulus: { action: "article-resource#onMarginChanged", view: %i[new edit] }

  field :default_retail_price, as: :price, only_on: :forms, tax: AppConfig::GLOBAL_TAX, input_mode: :brutto,
                               stimulus: { action: "article-resource#onDefaultRetailPriceChanged", view: %i[new edit] }

  field :min_preis, as: :price, only_on: :forms, tax: AppConfig::GLOBAL_TAX, input_mode: :brutto, nullable: true

  field :margin, as: :price, as_percent: true, only_on: :show,
                 visible: ->(resource:) { resource.model && resource.model.pricing_strategie_absolut? }

  field :margin, as: :text, only_on: :show,
                 visible: ->(resource:) { resource.model && resource.model.pricing_strategie_percentage? },
                 format_using: ->(value) { ActionController::Base.helpers.number_to_percentage(value).to_s }

  field :retail_price, as: :price, only_on: :index, input_mode: :brutto,
                       sortable: lambda { |query, direction|
                                   # Sorting by retail_price, which is a calculated value
                                   query.order(
                                     Arel.sql(
                                       "((default_retail_price + CASE
                                          WHEN pricing_strategie = 'percentage'
                                          THEN (margin * default_purchase_price / 100.0)
                                          WHEN pricing_strategie = 'absolut'
                                          THEN margin
                                          ELSE 0
                                          END) * ((#{AppConfig::GLOBAL_TAX} / 100.0) + 1)) #{direction}"
                                     )
                                   )
                                 }

  # field :sort_purchase_price, as: :price, only_on: :index, sortable: lambda { |query, direction|
  #   # Sorting by purchase_price, calculated dynamically
  #   query.joins(:supplier_sources)
  #        .order(Arel.sql("COALESCE(supplier_sources.purchase_price, articles.default_purchase_price) #{direction}"))
  # }, show_on: :index do |model|
  #   model.purchase_price
  # end

  field :images, as: :files, only_on: :forms

  sidebar do
    field :stock, as: :has_one, use_resource: ::SideBarStockResource,
                  only_on: :show, name: I18n.t(:stock, scope: "activerecord.attributes.article")
    field :images, as: :files, only_on: :show
    %i(updated_at created_at).each do |field_name|
      sidebar_field_date_time(
        self, field_name, show_seconds: true, name: I18n.t("shared.#{field_name}"), only_on: :show
      )
    end
    sidebar_field_date_time(
      self, :inventoried_at, show_seconds: true, name: I18n.t("activerecord.attributes.article.inventoried_at"),
                             only_on: :show
    )
    field :inventoried_by, as: :belongs_to, name: I18n.t("activerecord.attributes.article.inventoried_by"),
                           only_on: :show
  end

  tabs do
    tab -> { I18n.t('activerecord.attributes.stock_movement.other') } do
      field :stock_movements, as: :has_many, translation_key: :'activerecord.attributes.stock_movement',
                              hide_search_input: true, discreet_pagination: true, modal_create: true
    end

    tab -> { I18n.t('activerecord.attributes.supplier_article.other') } do
      field :supplier_articles, as: :has_many, translation_key: :'activerecord.attributes.supplier_article',
                                hide_search_input: true, modal_create: true
    end

    tab -> { I18n.t('activerecord.attributes.supplier_source.other') } do
      field :supplier_sources, as: :has_many, translation_key: :'activerecord.attributes.supplier_source',
                               hide_search_input: true, modal_create: true
    end

    tab -> { I18n.t('activerecord.attributes.repair_set.other') } do
      field :repair_sets, as: :has_many, translation_key: :'activerecord.attributes.repair_set',
                          hide_search_input: true, modal_create: true
    end

    tab -> { I18n.t('activerecord.attributes.stock_reservation.other') } do
      field :stock_reservations, as: :has_many, translation_key: :'activerecord.attributes.stock_reservation',
                                 hide_search_input: true, discreet_pagination: true
    end
  end

  # field :supplier_sources, as: :has_many
  # field :stock_movements, as: :has_many, modal_create: true, hide_search_input: true, discreet_pagination: true
  # field :supplier_articles, as: :has_many
  # field :stock_reservations, as: :has_many

  action Articles::MarkAsInventoriedAction
  action ::CloneAction
  filter Articles::ArticleGroupFilter
  filter Articles::EanFilter
  filter Articles::InventoriedFilter
end
