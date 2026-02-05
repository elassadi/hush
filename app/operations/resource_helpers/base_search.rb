module ResourceHelpers
  class BaseSearch < ::RecloudCore::DryBase
    attributes :search_query, :scope, :model, :search_by

    private

    def model_class
      model.to_s.classify.constantize
    end

    def search_by_uuid
      scope.where("uuid like ?", "#{model_class::MODEL_PREFIX}_#{search_query}%")
    end

    def search_by_sequence_id
      scope.where("sequence_id like ?", "#{search_query}%")
    end

    def search_method
      "search_by_#{search_by}"
    end

    def search_by_name
      # Split the search query into individual words
      words = search_query.strip.split(/\s+/)

      # Construct the search pattern with all words in the same order
      search_pattern = words.join('%')

      # Perform the search using ransack
      scope.ransack(name_matches: "%#{search_pattern}%").result(distinct: false)
    end
  end
end
