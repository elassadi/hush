module Debug
  class LowEvent < BaseEvent
    subscribe_to :debug, prio: 10

    def call
      CoreLogger.info "Sleep  1 seconds on Debug::LowEvent"
      sleep(3)
      CoreLogger.info "Debug::LowEvent"
      Success(true)
    end
  end
end
