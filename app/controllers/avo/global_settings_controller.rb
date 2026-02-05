module Avo
  class GlobalSettingsController < BaseResourceController
    def show
      setting_id = current_user.account.global_settings.id
      @model = @resource.find_record(setting_id, query: model_find_scope, params: {})

      redirect_to edit_resources_global_setting_path(@model)
    end

    def set_model
      params[:id] = current_user.account.global_settings.id

      @model = @resource.find_record(params[:id], query: model_find_scope, params:)
    end
  end
end
