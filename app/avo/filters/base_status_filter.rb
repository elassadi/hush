class BaseStatusFilter < Avo::Filters::BooleanFilter
  self.name = 'status_filter'

  def apply(_request, query, values)
    statuses = if values.is_a?(Hash)
                 values.select { |_k, v| v }.keys
               else
                 values
               end

    return query if statuses.blank?

    query.where((arguments[:status_field_name] || :status) => statuses)
  end

  def options
    klass = model_class || arguments[:model_class]
    status_field_name = arguments[:status_field_name] || :status

    klass.human_enum_names(status_field_name)
  end

  def model_class; end
end
