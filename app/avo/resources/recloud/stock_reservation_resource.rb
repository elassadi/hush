class StockReservationResource < ApplicationBaseResource
  include Concerns::ResourcesDefaultSetting.with_options
  include Concerns::AccountField

  include Concerns::DateResourceSidebar.with_fields(date_fields: %i(created_at updated_at))

  STATUS_OPTIONS = {
    gray: %w[pending low],
    info: %w[reserved normal],
    success: %w[fulfilled],
    warning: %w[],
    danger: %w[high]
  }.freeze

  self.title = :id
  self.includes = []
  self.authorization_policy = GlobalDataAccessPolicy
  # self.search_query = -> do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  # self.resolve_query_scope = ->(model_class:) do
  #   model_class.order(name: :asc)
  # end

  self.includes = []

  field :article, as: :belongs_to
  field :qty, as: :number
  # field :originator, as: :belongs_to
  field :status, as: :status_badge, options: STATUS_OPTIONS
  field :prio_badge, as: :status_badge, options: STATUS_OPTIONS
  field :issue, as: :uuid, as_html: true, link_to_resource: false do |model|
    next unless model.issue

    Avo::App.view_context.link_to "REP-#{model.issue.sequence_id}", "/resources/issues/#{model.issue.id}"
  end
end
