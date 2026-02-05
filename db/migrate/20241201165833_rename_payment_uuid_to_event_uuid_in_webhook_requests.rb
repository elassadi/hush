class RenamePaymentUuidToEventUuidInWebhookRequests < ActiveRecord::Migration[7.0]
  def change
    rename_column :webhook_requests, :payment_uuid, :event_uuid
  end
end
