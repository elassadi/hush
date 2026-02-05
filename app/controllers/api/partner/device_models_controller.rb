module Api
  module Partner
    class DeviceModelsController < ::Api::Partner::BaseController
      wrap_parameters :device_manufacturer, include: %i[]
      MAX_ITEMS = 400

      def index
        # models = DeviceModel.by_account.joins(:repair_sets).distinct
        # models = models.where(device_manufacturer_id: params[:device_manufacturer_id])
        # models = models.where('name LIKE ?', "%#{params[:search_term]}%") if params[:search_term].present?
        # render json: models.order(:name).limit(MAX_ITEMS).distinct
        render json: models_top30
      end

      def models_top30
        device_manufacturer_id = params[:device_manufacturer_id]
        search_term = params[:search_term]

        return if device_manufacturer_id.blank?

        ids = fetch_top_30_models(device_manufacturer_id).flatten.join(",").presence || "0"
        query = DeviceManufacturer
                .by_account.find(device_manufacturer_id)
                .device_models
                .includes(image_attachment: :blob)
                .order(Arel.sql("FIELD(device_models.id, #{ids}) desc, name "))
                .joins(:repair_sets)
                .merge(RepairSet.by_account)
                .order(name: :asc).limit(MAX_ITEMS).distinct
        query = query.where("device_models.name LIKE ?", "%#{search_term}%") if search_term.present?

        query
      end

      def fetch_top_30_models(manufacturer_id)
        key = "cache-top-30list-#{manufacturer_id}"
        Rails.cache.fetch(key, expires_in: 1.day) do
          fetch_top_30_models_from_database(manufacturer_id)
        end
      end

      def fetch_top_30_models_from_database(manufacturer_id)
        account_ids = [Current.account.id, Account.recloud.id]
        query =  Arel.sql("SELECT devices.device_model_id from devices
          join device_models as m on m.id = devices.device_model_id
          join device_manufacturers as manu on manu.id = m.device_manufacturer_id
          where manu.id='#{manufacturer_id}' AND devices.account_id in (#{account_ids.join(',')})
          group by devices.device_model_id order by  count(devices.device_model_id) desc
          limit 30")

        result = DeviceModel.connection.execute(query)

        result.to_a.reverse
      end

      def params_hsh
        params.require(:device_manufacturer).permit!
      end
    end
  end
end
