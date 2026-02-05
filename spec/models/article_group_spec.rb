require 'rails_helper'

RSpec.describe ArticleGroup, type: :model do
  subject(:model) { record }

  let(:record) { create(:article_group, name: "test group") }

  describe "#validations" do
    it { is_expected.to have_db_index :uuid }
    it { is_expected.to validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name).scoped_to(:account_id).case_insensitive }
  end
end
