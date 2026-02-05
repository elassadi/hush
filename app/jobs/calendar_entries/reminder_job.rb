# frozen_string_literal: true

module CalendarEntries
  class ReminderJob < ApplicationJob
    def perform(**_args)
      @stats = {
        started_at: Time.zone.now,
        total_entries: 0,
        successes: 0,
        failures: 0,
        failed_entries: [],
        success_details: []
      }

      remind_customers

      # @stats[:completed_at] = Time.zone.now
      # AdminMailer.reminder_job_mail(@stats).deliver_now
    end

    private

    def remind_customers
      calendar_entries.each do |calendar_entry|
        Current.user = calendar_entry.account.user
        result = CalendarEntries::ReminderTransaction.call(calendar_entry_id: calendar_entry.id)

        @stats[:total_entries] += 1
        if result.success?
          @stats[:successes] += 1
          @stats[:success_details] << { calendar_entry_id: calendar_entry.id, frequency: result.success[:frequency] }
        else
          @stats[:failures] += 1
          @stats[:failed_entries] << { calendar_entry_id: calendar_entry.id, error: result.failure }
        end
      end
    end

    def calendar_entries
      CalendarEntry.confirmed.where(account: accounts)
                   .where("start_at >= ? AND start_at <= ?", Time.zone.now, 1.day.from_now)
                   .where("reminded_at IS NULL OR reminded_at < ?", 22.hours.ago)
                   .where(entry_type: %w[repair regular])
    end

    def accounts
      @accounts ||= Account.status_active.select do |account|
        account.booking_settings.booking_reminder_enabled?
      end
    end
  end
end
