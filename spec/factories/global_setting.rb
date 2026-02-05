FactoryBot.define do
  factory :global_setting, class: "GlobalSetting" do
    account { ::Account.recloud }
    category { "global" }
  end
end
