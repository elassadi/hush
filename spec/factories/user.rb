# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    account { Account.recloud }

    name { Faker::Name.last_name }
    email { Faker::Internet.unique.email }
    password { "dasd;034F%" }
    role { association(:role, name: "technician", account:) }

    trait(:system_user) do
      email { User::SYSTEM_USER_EMAIL }
      role { association(:role, name: "admin", account:) }
    end
    trait(:demo_user) do
      email { "demo@hush-haarentfernung.de" }
      role { association(:role, name: "account_admin", account:) }
    end
    trait(:public_api) do
      api_only { true }
      role { association(:role, :public_api) }
      api_tokens { build_list :api_token, 1 }
    end
  end
end
