FactoryBot.define do
  factory :booking_setting, class: "BookingSetting" do
    account { Account.recloud }
    category { "booking" }
  end
end
