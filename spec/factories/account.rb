FactoryBot.define do
  factory :account do
    name { Faker::Company.unique.name }
    status { :active }
    account_type { :customer }
    legal_form { :GmbH }
    email { Faker::Internet.unique.email }

    factory(:RECLOUD_ACCOUNT) do
      uuid { Constants::RECLOUD_ACCOUNT_UUID }
      account_type { :customer }
      legal_form { :GmbH }
    end

    factory(:DEMO_ACCOUNT) do
      email { "demo@hush-haarentfernung.de" }
      name { "demo-account" }
      account_type { :customer }
      legal_form { :GmbH }
    end
    after(:create) do |account|
      account.merchants << create(:merchant, affiliate_type: "master", master: true, account:)
    end
  end
end
