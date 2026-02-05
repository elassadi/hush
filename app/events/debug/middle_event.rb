module Debug
  class MiddleEvent < BaseEvent
    subscribe_to :debug, prio: 50

    def call
      CoreLogger.info "Sleep  3 seconds on Debug::MiddleEvent"
      sleep(3)
      CoreLogger.info "Debug::MiddleEvent"
      Success(true)
    end
  end
end
