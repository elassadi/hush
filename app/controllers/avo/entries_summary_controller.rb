module Avo
  class EntriesSummaryController < Avo::ApplicationController
    def show
      return unless params[:via_resource_class].present? && params[:via_resource_id].present?

      @via_resource = Avo::App.get_resource(params[:via_resource_class]).dup
      @via_model = @via_resource.find_record params[:via_resource_id], params:
    end
  end
end
