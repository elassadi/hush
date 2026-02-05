FactoryBot.define do
  factory :address do
    account { ::Account.recloud }

    transient do
      addressable { nil }
    end
    addressable_id { addressable&.id }
    addressable_type { addressable&.class&.name }
    country { "DE" }
    post_code { Faker::Address.zip_code }
    city { Faker::Address.city }
    street { Faker::Address.street_name }
    house_number { Faker::Address.building_number }
    status { :draft }

    trait :active do
      status { :active }
    end

    trait :archived do
      status { :archived }
    end
  end
end
