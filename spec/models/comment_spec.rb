require 'rails_helper'

RSpec.describe Comment, type: :model do
  include_context "setup system user"

  subject(:model) { record }

  let(:customer) { create(:customer, owner: system_user) }
  let(:record) { create(:comment, commentable: customer, owner: system_user) }

  describe "#validations" do
    it { is_expected.to have_db_index :uuid }
    it { is_expected.to validate_length_of(:body).is_at_most(Comment::BODY_MAX_LENGTH) }
    it { is_expected.to validate_presence_of(:body) }
  end
end
