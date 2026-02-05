FactoryBot.define do
  factory :application_setting, class: "ApplicationSetting" do
    account { ::Account.recloud }
    category { "application" }
  end
end
