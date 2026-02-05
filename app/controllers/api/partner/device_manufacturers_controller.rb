module Api
  module Partner
    class DeviceManufacturersController < ::Api::Partner::BaseController
      wrap_parameters :device_manufacturer, include: %i[]
      MAX_ITEMS = 40
      def index
        manufacturers = fetch_manufacturers
        if params[:search_term].present?
          manufacturers = manufacturers.where('device_manufacturers.name LIKE ?',
                                              "%#{params[:search_term]}%")
        end

        render json: manufacturers
      end

      def fetch_manufacturers
        query = DeviceManufacturer.by_account.joins(:repair_sets).order(
          Arel.sql(
            %{
              FIELD(device_manufacturers.name, "Motorola", "Oppo", "Nokia", "LG",
                "Google", "Sony", "Xiaomi", "Huawei", "Samsung", "Apple") desc, device_manufacturers.name
            }
          )
        )
        query
          .merge(RepairSet.by_account)
          .select("device_manufacturers.id, device_manufacturers.name,device_manufacturers.account_id ")
          .limit(MAX_ITEMS).distinct
      end

      def params_hsh
        params.require(:device_manufacturer).permit!
      end
    end
  end
end
