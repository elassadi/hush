class DocumentResource < ApplicationBaseResource
  include Concerns::SequenceResourceSetting
  include Concerns::AccountField
  include Concerns::DateResourceSidebar

  self.hide_from_global_search = true
  self.search_query = lambda {
    ResourceHelpers::SearchEngine.call(search_query: params[:q], global: true, scope:,
                                       model: :document).success
  }

  STATUS_BADGE_OPTIONS = {
    success: "active",
    warning: %w[archived],
    danger: %w[deleted]
  }.freeze

  self.title = :title
  self.includes = []

  field :file, as: :file, hide_on: :index

  field_link :file, only_on: :index, shorten: false,
                    text: ->(record) { record.file.blob&.filename.to_s },
                    href: ->(record) { record.download_url }
  field_date_time :created_at, only_on: :index

  filter ::Documents::TypeFilter
end
