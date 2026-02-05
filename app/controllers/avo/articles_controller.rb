# This controller has been generated to enable Rails' resource routes.
# You shouldn't need to modify it in order to use Avo.
module Avo
  class ArticlesController < BaseResourceController
    def show
      super
      respond_to do |format|
        format.json do
          render json: article
        end
        format.html
      end
    end

    private

    def article
      @model.attributes.merge({
                                retail_price: @model.retail_price
                              })
    end
  end
end
