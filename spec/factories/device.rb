FactoryBot.define do
  factory :device do
    account { ::Account.recloud }
    serial_number { Faker::Lorem.characters(number: 10) }
    device_model { association(:device_model) }
    device_color { association(:device_color, device_model:) }
  end
end
