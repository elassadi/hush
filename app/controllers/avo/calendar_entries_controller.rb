# This controller has been generated to enable Rails' resource routes.
# You shouldn't need to modify it in order to use Avo.

module Avo
  class CalendarEntriesController < BaseResourceController
    def save_model
      return super unless @view.in? %i[create update]

      assign_event_dates
      @view == :create ? create_calendar_entry : update_calendar_entry
    end

    def index
      super
      start_at = params[:start]&.to_date
      end_date = params[:end]&.to_date

      respond_to do |format|
        format.json do
          result = fetch_entries_for_calendar_tool(start_at, end_date) if start_at.present? && end_date.present?
          if result.success?
            render json: result.success, status: :ok
          else
            render json: { errors: Array(result.failure).flatten }, status: :unprocessable_entity
          end
        end
        format.html
      end
    end

    # Override update_success_action
    def update_success_action
      respond_to do |format|
        format.json do
          render json: { message: 'Update successful' }, status: :ok
        end
        format.any { super } # Defer to super method for other formats (e.g., HTML, Turbo Stream)
      end
    end

    # Override update_fail_action
    def update_fail_action
      respond_to do |format|
        format.json do
          render json: { message: update_fail_message, errors: @model.errors }, status: :unprocessable_entity
        end
        format.any { super } # Defer to super method for other formats (e.g., HTML)
      end
    end

    private

    def fetch_entries_for_calendar_tool(start_at, end_date)
      CalendarEntries::FetchAllQuery.call(start_at:, end_date:)
    end

    def create_calendar_entry
      assign_calendarable
      result = IssueCalendarEntries::CreateTransaction.call(attributes: entry_attributes.merge(
        confirmed_at: entry_attributes["confirm_and_notify_customer"] ? Time.zone.now : nil,
        notify_customer: entry_attributes["confirm_and_notify_customer"]
      ))

      if result.success?
        @model = result.success
        return true
      end

      @model = result.failure
      @errors = Array(@model.errors)

      nil
    end

    def update_calendar_entry
      result = IssueCalendarEntries::UpdateTransaction.call(
        calendar_entry_id: @model.id,
        attributes: entry_attributes.slice(*%w[start_at end_at category event_color notes all_day
                                               notify_customer entry_type])
          .merge(
            {
              merchant_id:
            }
          )
      )

      if result.success?
        @model = result.success
        return true
      end

      @model = result.failure
      @errors = Array(@model.errors)
      nil
    end

    def entry_attributes
      @model.attributes.slice(
        *%w[
          entry_type calendarable_id calendarable_type all_day start_at end_at notify_customer
          confirm_and_notify_customer
        ]
      ).merge(
        category: @model.category,
        event_color: @model.event_color,
        notes: @model.notes,
        merchant_id:,
        selected_repair_set_id: @model.selected_repair_set_id
      ).with_indifferent_access.to_h
    end

    def assign_calendarable
      case @model.entry_type
      when 'regular', 'repair', 'customer'
        @model.calendarable ||= @model.customer
      when 'user'
        @model.calendarable ||= @model.user
      when 'blocker'
        @model.calendarable ||= Current.user
      end
    end

    def assign_event_dates
      @model.start_at = parse_event_start
      @model.end_at = parse_event_end
    end

    def merchant_id
      Current.user.branch.id
    end

    # def assign_event_dates
    #   event_start_date = params[:fake_event_start]
    #   event_end_date = params[:fake_event_end]
    #   event_start_time = params[:calendar_entry][:event_start_time]
    #   event_end_time = params[:calendar_entry][:event_end_time]

    #   if event_start_date.present? && event_start_time.present?
    #     event_start = Time.zone.parse("#{event_start_date} #{event_start_time}")
    #   end

    #   if event_end_date.present? && event_end_time.present?
    #     event_end = Time.zone.parse("#{event_end_date} #{event_end_time}")
    #   end

    #   if params[:start].present? && params[:end].present?
    #     event_start = Time.zone.parse(params[:start])
    #     event_end = Time.zone.parse(params[:end])
    #   elsif params[:start].present? && params[:all_day].present?
    #     event_start = Date.parse(params[:start])
    #     @model.all_day = true
    #   end

    #   @model.start_at = event_start
    #   @model.end_at = event_end
    # end

    def parse_event_start
      event_start_date = params[:fake_event_start]
      event_start_time = params[:calendar_entry][:event_start_time]

      if event_start_date.present? && event_start_time.present?
        return Time.zone.parse("#{event_start_date} #{event_start_time}")
      end

      if params[:start].present?
        return params[:all_day].present? ? Date.parse(params[:start]) : Time.zone.parse(params[:start])
      end

      nil
    end

    def parse_event_end
      event_end_date = params[:fake_event_end]
      event_end_time = params[:calendar_entry][:event_end_time]

      if event_end_date.present? && event_end_time.present?
        return Time.zone.parse("#{event_end_date} #{event_end_time}")
      end

      return Time.zone.parse(params[:end]) if params[:end].present?

      nil
    end
  end
end
