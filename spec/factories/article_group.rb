FactoryBot.define do
  factory :article_group do
    account { ::Account.recloud }
    name { Faker::Name.last_name }
  end
end
