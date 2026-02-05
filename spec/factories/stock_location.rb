FactoryBot.define do
  factory :stock_location do
    name { Faker::Address.state }
  end
end
