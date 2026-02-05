FactoryBot.define do
  factory :template do
    account { ::Account.recloud }
    subject { "subject" }
  end
end
