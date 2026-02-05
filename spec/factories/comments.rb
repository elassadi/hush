FactoryBot.define do
  factory :comment do
    account { ::Account.recloud }
    transient do
      commentable { nil }
    end
    commentable_id { commentable&.id }
    commentable_type { commentable&.class&.name }
    teaser { Faker::Lorem.paragraph_by_chars(number: 200) }
    body { Faker::Lorem.paragraph_by_chars(number: 200) }
    status { :active }

    trait :archive do
      status { :archive }
    end
  end
end
