module Avo
  class BookingSettingsController < BaseResourceController
    def show
      setting_id = current_user.account.booking_settings.id
      @model = @resource.find_record(setting_id, query: model_find_scope, params: {})

      redirect_to edit_resources_booking_setting_path(@model)
    end

    def set_model
      params[:id] = current_user.account.booking_settings.id

      @model = @resource.find_record(params[:id], query: model_find_scope, params:)
    end
  end
end
