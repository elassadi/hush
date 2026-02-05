FactoryBot.define do
  factory :taxonomy_record do
    account { ::Account.recloud }
    name { "name" }
    trait :with_parent do
      after(:build) do |record|
        record.parent = create(:taxonomy_record)
      end
    end
  end
end
