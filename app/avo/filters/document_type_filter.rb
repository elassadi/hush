class DocumentTypeFilter < Avo::Filters::BooleanFilter
  self.name = "Published filter"

  def apply(_request, query, values)
    return query unless options_exists(values) && documentable_classes(values).present?

    query.where(documentable_type: documentable_classes(values))
  end

  def options_exists(values)
    exists = true
    values.each_key do |key|
      unless options.key?(key.to_sym)
        exists = false
        break
      end
    end
    exists
  end

  def options
    {
      product: "Produktdokumente",
      provider: "Versichererdokumente"
    }
  end

  def documentable_class
    {
      product: Product,
      provider: Provider
    }.with_indifferent_access
  end

  def documentable_classes(options)
    options.filter_map do |key, enabled|
      documentable_class[key] if enabled
    end
  end
end
