class ArticleGroupResource < ApplicationBaseResource
  include Concerns::ResourcesDefaultSetting.with_options
  include Concerns::AccountField
  include Concerns::DateResourceSidebar

  self.title = :name
  self.includes = []
  self.resolve_query_scope = lambda { |model_class:|
    model_class.order(name: :asc)
  }

  field :name, as: :text
  field :description, as: :textarea

  filter ByAccountFilter
end
