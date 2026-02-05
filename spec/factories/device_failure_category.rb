FactoryBot.define do
  factory :device_failure_category do
    account { ::Account.recloud }
    name { Faker::Lorem.characters(number: 10) }
  end
end
