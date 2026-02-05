class StockAreaResource < ApplicationBaseResource
  include Concerns::ResourcesDefaultSetting.with_options
  include Concerns::AccountField

  self.title = :full_name
  self.includes = []

  field :stock_location, as: :belongs_to
  field :name, as: :text
end
