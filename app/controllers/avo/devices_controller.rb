# This controller has been generated to enable Rails' resource routes.
# You shouldn't need to modify it in order to use Avo.

module Avo
  class DevicesController < BaseResourceController
    def list_repair_sets
      device = Device.by_account.find(params[:id])
      device_failure_categories = params[:device_failure_categories].split(",").map(&:strip)
      query = matching_scope(
        account: Current.account,
        input_device_failure_category_name: device_failure_categories,
        device_model: device.device_model,
        device_color: device.device_color
      )

      if params[:issue_id].present?
        issue = Issue.by_account.find(params[:issue_id])
        repair_set_ids = issue.repair_set_ids
      end
      json_data = query.map do |repair_set|
        [repair_set.id, repair_set.name_with_price_and_stock_status, repair_set_ids&.include?(repair_set.id)]
      end

      render json: json_data
    end

    def list_devices_for_customer
      # render json: Device.by_account.with_no_issues_for_customer(params[:customer_id])

      json_data = Customer.by_account.find(params[:customer_id]).devices.by_account.map do |device|
        [device.id, device.title]
      end
      render json: json_data
    end

    def list_colors
      render json: device_colors(params[:device_model_id])
    end

    def fetch_by_imei
      render json: reference_device(params[:imei])
    end

    def save_model
      # return super unless @view == :create
      return super unless @view.in? %i[create update]

      @view == :create ? create_device : update_device
    end

    private

    def matching_scope(account:, input_device_failure_category_name:, device_model:, device_color: nil)
      query = RepairSet.where(
        account:,
        device_model:
      ).order(:name)

      if input_device_failure_category_name.present?
        query = query.where(
          device_failure_category: DeviceFailureCategory
            .by_account.where(name: input_device_failure_category_name)
        )
      end

      if query.where(device_color:).count.positive?
        query.where(device_color: [nil, device_color])
      else
        query
      end
    end

    def create_device
      result = Devices::CreateTransaction.call(**device_attributes)
      if result.success?
        @model = result.success
        return true
      end

      @model = result.failure
      @errors = Array.wrap([result.failure, @model.errors.full_messages].flatten).compact
      nil
    end

    def update_device
      result = Devices::UpdateTransaction.call(device_id: @model.id, **device_attributes)
      if result.success?
        @model = result.success
        return true
      end
      @model = result.failure
      @errors = Array.wrap([result.failure, @model.errors.full_messages].flatten).compact
      nil
    end

    def device_attributes
      @model.attributes.slice(
        *%w[device_model_id device_color_id imei serial_number]
      ).merge(
        unlock_pattern: @model.unlock_pattern,
        unlock_pin: @model.unlock_pin
      )
    end

    def device_colors(device_model_id)
      DeviceModel.by_account.find(device_model_id)
                 .device_colors.pluck(:id, :name)
    end

    def reference_device(_imei)
      device = Device.reference_device(params[:imei])
      return unless device&.device_model

      {
        name: device.device_model.name,
        device_model_id: device.device_model_id
      }
    end
  end
end
