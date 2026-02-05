# This controller has been generated to enable Rails' resource routes.
# You shouldn't need to modify it in order to use Avo.

module Avo
  class RepairSetsController < BaseResourceController
    def show
      # RecentSearchItems::SaveOperation.call(model: @model)
      super
      respond_to do |format|
        format.json { render json: @model }
        format.html
      end
    end
    # def save_model

    #   @model.name = params[:template][:name] if @model.name.blank? && params[:template][:name].present?
    #   super
    # end

    def create
      result = super
      via_cloned_id = params.dig(:repair_set, :via_cloned_id)
      clone_repair_set_entries(via_cloned_id.to_i) if via_cloned_id.present? && @model.persisted?
      result
    end

    private

    def clone_repair_set_entries(via_cloned_id)
      cloned_repair_set = RepairSet.find(via_cloned_id)
      cloned_repair_set.repair_set_entries.each do |entry|
        @model.repair_set_entries.create(entry.attributes.except("id", "repair_set_id", "uuid"))
      end
    end
  end
end
