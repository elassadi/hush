module Templates
  class TypeFilter < Avo::Filters::BooleanFilter
    self.name = I18n.t(:'filters.by_template_type_filter.name')

    def apply(_request, query, values)
      types = if values.is_a?(Hash)
                values.select { |_k, v| v }.keys
              else
                values
              end
      return query if types.blank?

      query.where(template_type: types)
    end

    def options
      Template.human_enum_names(:template_type)
    end
  end
end
