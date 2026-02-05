FactoryBot.define do
  factory :device_color do
    account { ::Account.recloud }
    device_model
    name { "Grau" }
  end
end
