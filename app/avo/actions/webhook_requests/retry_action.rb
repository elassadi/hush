module WebhookRequests
  class RetryAction < ::ApplicationBaseAction
    self.name = t(:name)
    self.message = t(:message)
    self.icon = "heroicons/outline/refresh"
    # self.icon_class = "text-green-500"

    self.visible = -> { current_user.can?(:retry_webhook_requests, resource.model) }

    def handle(**args)
      args[:models].each do |model|
        authorize_and_run(:retry_events, model) do |webhook_request|
          do_retry(webhook_request)
        end
      end
    end

    private

    def do_retry(webhook_request)
      WebhookRequest.create!(
        webhook_request.attributes.with_indifferent_access.merge(
          { retry_counter: 0, status: :pending, payment_uuid: nil }
        ).except(:id, :created_at, :updated_at)
      )
      WebhookJob.perform_later(request.id)
    end
  end
end
