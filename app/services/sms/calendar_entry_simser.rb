module Sms
  class CalendarEntrySimser < BaseSimser
    attributes :calendar_entry, :template

    def record
      calendar_entry
    end
  end
end
