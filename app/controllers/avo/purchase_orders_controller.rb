# This controller has been generated to enable Rails' resource routes.
# You shouldn't need to modify it in order to use Avo.

module Avo
  class PurchaseOrdersController < BaseResourceController
    def split_helper
      respond_to do |format|
        format.turbo_stream do
          render :split_helper, locals: { purchase_order_entries: }
        end
      end
    end

    private

    def purchase_order_entries
      purchase_order = PurchaseOrder.by_account.find(params[:id])
      purchase_order.purchase_order_entries.order(created_at: :desc)
    end
  end
end
