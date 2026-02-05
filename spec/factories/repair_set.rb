FactoryBot.define do
  factory :repair_set do
    account { ::Account.recloud }
    name { Faker::Commerce.product_name }
    device_failure_category { create(:device_failure_category, name: "akku") }
    device_model { create(:device_model, name: "iPhone 11") }
  end
end
