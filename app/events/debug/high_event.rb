module Debug
  class HighEvent < BaseEvent
    subscribe_to :debug, prio: 100

    def call
      CoreLogger.info "Sleep  3 seconds on Debug::HighEvent"
      sleep(3)
      CoreLogger.info "Debug::HighEvent"
      Success(true)
    end
  end
end
