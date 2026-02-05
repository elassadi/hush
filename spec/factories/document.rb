FactoryBot.define do
  factory :document do
    account { ::Account.recloud }

    transient do
      documentable { nil }
    end
    documentable_id { documentable&.id }
    documentable_type { documentable&.class&.name }

    file { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/dummy.txt')) }
  end
end
