module Debug
  class NoPrioEvent < BaseEvent
    subscribe_to :debug

    def call
      CoreLogger.info "Sleep 1 seconds on Debug::NoPrioEvent"
      CoreLogger.info "Debug::NoPrioEvent"
      Success(true)
    end
  end
end
