module Documents
  class TypeFilter < Avo::Filters::BooleanFilter
    self.name = I18n.t(:'filters.by_document_type_filter.name')

    def apply(_request, query, values)
      types = if values.is_a?(Hash)
                values.select { |_k, v| v }.keys
              else
                values
              end
      return query if types.blank?

      query.where(type: types)
    end

    def options
      I18n.t("activerecord.attributes.document.document_types")
    end
  end
end
