module RecentSearchItems
  class SaveOperation < BaseOperation
    attributes :model

    MAX_ITEMS = 5

    def call
      save_item
    end

    private

    def save_item
      key = redis_key
      model_data = { id: model.id, class_name: model.class.name }.to_json
      recent_searches = Rails.cache.fetch(key) { [] }

      existing_index = recent_searches.index { |item| item == model_data }

      if existing_index
        recent_searches.unshift(recent_searches.delete_at(existing_index))
      else
        recent_searches.prepend(model_data)
      end

      recent_searches = recent_searches.take(MAX_ITEMS)
      Rails.cache.write(key, recent_searches)
    end

    def redis_key
      "#{model.class.to_s.underscore}_recent_searches_#{Current.user.id}".downcase
    end
  end
end
