# frozen_string_literal: true

module Avo
  class MobileController < Avo::ApplicationController
    before_action :authorize_calendar_entry, except: %i[calendar_entries_confirm calendar_entries_cancel calendar_entries_update]

    # GET /resources/mobile/customers?q=...
    def customers_index
      q = ActiveRecord::Base.sanitize_sql_like(params[:q].to_s)
      pattern = "%#{q}%"
      customers = Customer.by_account
                          .where(merchant_id: merchant_id)
                          .where("first_name LIKE ? OR last_name LIKE ? OR mobile_number LIKE ? OR email LIKE ?",
                                 pattern, pattern, pattern, pattern)
                          .limit(20)
                          .map { |c| { id: c.id, name: c.name, mobile_number: c.mobile_number, email: c.email } }
      render json: customers
    end

    # POST /resources/mobile/customers
    def customers_create
      result = Customers::CreateOperation.call(
        attributes: customer_params.merge(merchant_id: merchant_id).with_indifferent_access,
        skip_address: true
      )
      if result.success?
        customer = result.success
        render json: { id: customer.id, name: customer.name, mobile_number: customer.mobile_number, email: customer.email }
      else
        render json: { errors: result.failure }, status: :unprocessable_entity
      end
    end

    # POST /resources/mobile/calendar_entries
    def calendar_entries_create
      result = IssueCalendarEntries::Api::CreateTransaction.call(params: calendar_entry_params)
      if result.success?
        entry = result.success
        render json: entry.as_json, status: :created
      else
        render json: { errors: result.failure }, status: :unprocessable_entity
      end
    end

    # POST /resources/mobile/calendar_entries/:id/confirm
    def calendar_entries_confirm
      entry = CalendarEntry.find(params[:id])
      Current.user.authorize!(:confirm, entry)
      result = CalendarEntries::ConfirmTransaction.call(calendar_entry_id: entry.id, notify_customer: false)
      if result.success?
        render json: result.success.as_json, status: :ok
      else
        render json: { errors: Array(result.failure) }, status: :unprocessable_entity
      end
    end

    # POST /resources/mobile/calendar_entries/:id/cancel
    def calendar_entries_cancel
      entry = CalendarEntry.find(params[:id])
      Current.user.authorize!(:cancel, entry)
      result = CalendarEntries::CancelTransaction.call(calendar_entry_id: entry.id, notify_customer: false)
      if result.success?
        render json: result.success.as_json, status: :ok
      else
        render json: { errors: Array(result.failure) }, status: :unprocessable_entity
      end
    end

    # PATCH /resources/mobile/calendar_entries/:id (notes only)
    def calendar_entries_update
      entry = CalendarEntry.find(params[:id])
      Current.user.authorize!(:update, entry)
      if entry.update(notes: params[:notes])
        render json: entry.as_json, status: :ok
      else
        render json: { errors: entry.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def authorize_calendar_entry
      Current.user.authorize!(:create, CalendarEntry)
    end

    def merchant_id
      Current.user.branch.id
    end

    def customer_params
      params.permit(:first_name, :last_name, :mobile_number, :email, :salutation)
            .to_h
            .merge(skip_address_validation: true)
    end

    def calendar_entry_params
      customer_data = if params[:customer_id].present?
                        c = Customer.by_account.where(merchant_id: merchant_id).find(params[:customer_id])
                        {
                          first_name: c.first_name,
                          last_name: c.last_name,
                          email: c.email,
                          mobile_number: c.mobile_number,
                          salutation: c.salutation
                        }
                      else
                        {
                          first_name: params.dig(:customer, :first_name),
                          last_name: params.dig(:customer, :last_name),
                          email: params.dig(:customer, :email),
                          mobile_number: params.dig(:customer, :mobile_number),
                          salutation: params.dig(:customer, :salutation) || "female"
                        }
                      end
      {
        start_at: params[:start_at],
        end_at: params[:end_at],
        merchant_id: merchant_id,
        customer: customer_data
      }.tap do |h|
        h[:notes] = params[:notes] if params[:notes].present?
      end
    end
  end
end
