module Api
  module Partner
    class RepairSetsController < ::Api::Partner::BaseController
      def index
        models = RepairSet.by_account.all
        models = models.where(device_model_id: params[:device_model_id]) if params[:device_model_id].present?
        models = models.where('name LIKE ?', "%#{params[:search_term]}%") if params[:search_term].present?
        render json: models.order(:name)
      end
    end
  end
end
