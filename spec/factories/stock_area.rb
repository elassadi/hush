FactoryBot.define do
  factory :stock_area do
    name { Faker::Address.city }
  end
end
