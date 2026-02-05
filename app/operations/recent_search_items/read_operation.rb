module RecentSearchItems
  class ReadOperation < BaseOperation
    attributes :class_name

    def call
      read_items
    end

    private

    def read_items
      recent_searches = Rails.cache.fetch(redis_key) { [] }

      # Parse the JSON strings back into Ruby hashes
      Success(recent_searches.map { |item| JSON.parse(item) })
    end

    def redis_key
      "#{class_name}_recent_searches_#{Current.user.id}".downcase
    end
  end
end
