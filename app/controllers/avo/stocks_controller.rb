# This controller has been generated to enable Rails' resource routes.
# You shouldn't need to modify it in order to use Avo.

module Avo
  class StocksController < BaseResourceController
    def areas
      render json: stock_areas(params[:location])
    end

    def default_stock
      render json: default_stock_item_by_article(params[:article])
    end

    private

    def stock_areas(location)
      stock_location = StockLocation.by_account.find(location)
      StockArea.by_account.where(stock_location:).pluck(:id, :name)
    end

    def default_stock_item_by_article(article_id)
      item = StockItem.by_account.where(article_id:).order(in_stock: :desc).first

      area = if item
               item.stock_area
             else
               location = StockLocation.by_account.primary
               location&.stock_areas&.first
             end

      return {} unless area

      {
        location: area.stock_location.id,
        area: area.id
      }
    end
  end
end
