# This controller has been generated to enable Rails' resource routes.
# You shouldn't need to modify it in order to use Avo.

module Avo
  class CustomersController < PatchedBaseResourceController
    def save_model_transaction
      if @view == :create
        Customers::CreateTransaction.call(attributes:)
      else
        Customers::UpdateTransaction.call(customer_id: @model.id, attributes:)
      end
    end

    def attributes
      @model.attributes.slice(
        *%w[salutation first_name last_name company_name street house_number city post_code
            email phone_number mobile_number]
      )
    end
  end
end
