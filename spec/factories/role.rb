# frozen_string_literal: true

FactoryBot.define do
  factory :role do
    name { "role_name" }
    status { "active" }
    trait :api_reader do
      name { :api_reader }
      after(:create) do |role|
        create(:ability, resources: ["Client"], action_tags: ["read"], role:)
      end
    end

    trait :public_api do
      name { :public_api }
      after(:create) do |role|
        create(:ability, resources: %w(CalendarEntry), action_tags: %w[read], role:)
      end
    end
  end
end
