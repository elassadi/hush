module Events
  class RetryAction < ::ApplicationBaseAction
    self.name = t(:name)
    self.message = t(:message)
    self.icon = "heroicons/outline/refresh"
    # self.icon_class = "text-green-500"

    self.visible = -> { current_user.can?(:retry_events, resource.model) }

    def handle(**args)
      args[:models].each do |model|
        authorize_and_run(:retry_events, model) do |event|
          do_retry(event)
        end
      end
    end

    private

    def do_retry(event)
      Event.broadcast(event.name.to_sym, **event.data)
      Success(true)
    end
  end
end
