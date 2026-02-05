module Stocks
  class StatusFilter < BaseStatusFilter
    self.name = 'Article Statuse'

    def model_class = ::Article
  end
end
