module Stocks
  class ArticleGroupFilter < Avo::Filters::MultipleSelectFilter
    self.name = 'Articlegroup Filter'

    def apply(_request, query, values)
      groups = if values.is_a?(Hash)
                 values.select { |_k, v| v }.keys
               else
                 values
               end
      return query if groups.blank?

      query.where(article_group_id: groups)
    end

    def options
      ArticleGroup.by_account.pluck(:id, :name).to_h
    end
  end
end
