FactoryBot.define do
  factory :customer do
    account { ::Account.recloud }
    salutation { "male" }
    last_name { Faker::Name.last_name }
    first_name { Faker::Name.first_name }
    company_name { Faker::Company.unique.name }
    email { Faker::Internet.unique.email }
    phone_number { Faker::PhoneNumber.numerify("+49############") }
    merchant
    street { Faker::Address.street_name }
    house_number { Faker::Address.building_number }
    city { Faker::Address.city }
    post_code { Faker::Address.zip_code }
    country { "DE" }
    # trait :in_the_past do
    #   published_at { 2.days.ago }
    # end
  end
end
