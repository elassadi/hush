FactoryBot.define do
  factory :device_manufacturer do
    account { ::Account.recloud }
    name { Faker::Company.unique.name }
  end
end
