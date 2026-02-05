# This controller has been generated to enable Rails' resource routes.
# You shouldn't need to modify it in order to use Avo.

# This controller has been generated to enable Rails' resource routes.
# You shouldn't need to modify it in order to use Avo.

module Avo
  class PurchaseOrderEntriesController < BaseResourceController
    private

    def save_model
      return super unless @view == :create

      # TODO: - this is a hack to get the purchase price from the article
      @model.price = @model.article.purchase_price

      super
    end
  end
end
