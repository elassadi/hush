namespace :redis do
  desc "Delete all user abilities cache keys from Redis"
  task clean_abillities: :environment do
    require 'redis'

    def delete_user_abilities_cache_keys
      redis = Redis.new
      pattern = "abilities::account::*::user::*::abilities::*"
      cursor = 0
      loop do
        cursor, keys = redis.scan(cursor, match: pattern, count: 100)
        keys.each do |key|
          redis.del(key)
        end
        break if cursor.to_i == 0
      end

      puts "Deleted all cache keys matching the pattern: #{pattern}"
    end

    delete_user_abilities_cache_keys
  end
end
