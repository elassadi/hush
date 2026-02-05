module ResourceHelpers
  class DeviceSearch < BaseSearch
    attributes :search_query, :scope, :model, :search_by

    def call
      proccess_search
    end

    private

    def search_method
      "search_by_#{search_by}"
    end

    def proccess_search
      return Success(send(search_method)) if respond_to?(search_method, true)

      Success(scope.none)
    end

    def search_by_uuid
      scope.where(uuid: search_query)
    end

    def search_by_model_name
      scope.joins(:device_model).where("device_models.name like ?", "%#{search_query}%")
    end

    def search_by_imei
      scope.where("imei like ?", "#{search_query}%")
    end

    def search_by_serial_number
      scope.where("serial_number like ?", "#{search_query}%")
    end
  end
end
