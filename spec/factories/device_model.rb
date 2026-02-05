FactoryBot.define do
  factory :device_model do
    account { ::Account.recloud }
    device_manufacturer
    name { "EinPhone 100" }
  end
end
