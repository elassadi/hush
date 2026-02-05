FactoryBot.define do
  factory :merchant, class: "::Merchant" do
    account { ::Account.recloud }
    affiliate_type { "partner" }
    salutation { "male" }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    company_name { Faker::Company.unique.name }
    email { Faker::Internet.unique.email }
    accounting_email { Faker::Internet.unique.email }
    phone_number { Faker::PhoneNumber.phone_number_with_country_code }
    mobile_number { Faker::PhoneNumber.phone_number_with_country_code }
  end
end
