# This controller has been generated to enable Rails' resource routes.
# You shouldn't need to modify it in order to use Avo.

module Avo
  class IssueCalendarEntriesController < BaseResourceController
    def save_model
      # assign_calendarable
      assign_customer
      assign_event_dates
      super
    end

    private

    def assign_calendarable
      case @model.entry_type
      when 'regular', 'repair', 'customer'
        @model.calendarable ||= @model.customer
      when 'user'
        @model.calendarable ||= @model.user
      end
    end

    def assign_customer
      @model.customer = @model.calendarable.customer
    end

    def assign_event_dates
      event_start_date = params[:fake_event_start]
      event_end_date = params[:fake_event_end]
      event_start_time = params[:calendar_entry][:event_start_time]
      event_end_time = params[:calendar_entry][:event_end_time]

      if event_start_date.present? && event_start_time.present?
        event_start = Time.zone.parse("#{event_start_date} #{event_start_time}")
      end

      if event_end_date.present? && event_end_time.present?
        event_end = Time.zone.parse("#{event_end_date} #{event_end_time}")
      end

      @model.start_at = event_start
      @model.end_at = event_end
    end
  end
end
