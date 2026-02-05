module DeviceModelCategories
  class NameFilter < Avo::Filters::TextFilter
    self.name = I18n.t("filters.device_model_categories.name_filter.name")
    self.button_label = I18n.t("filters.device_model_categories.name_filter.button_label")

    def apply(_request, query, value)
      query.where('name LIKE ?', "%#{value}%")
    end
  end
end
