module Articles
  class InventoriedFilter < Avo::Filters::BooleanFilter
    self.name = 'Inventarisiert Filter'

    def apply(_request, query, values)
      values = if values.is_a?(Hash)
                 values.select { |_k, v| v }.keys
               else
                 values
               end

      return query if values.blank?

      query.where.not(inventoried_at: nil)
    end

    def options
      { 'inventoried' => "Ja" }
    end
  end
end
