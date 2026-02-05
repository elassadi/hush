# frozen_string_literal: true

class BaseEvent < ::RecloudCore::DryBase
  optional_attributes :current_user_id

  class << self
    attr_accessor :event_name, :prio

    def subscribe_to(event_name, prio: nil)
      self.event_name = event_name
      self.prio = prio
    end
  end
end
