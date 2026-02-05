require 'rails_helper'

RSpec.describe User, type: :model do
  subject { record }
  let(:role) { create(:role, name: "test") }
  let(:record) { create(:user, role:) }

  include_context "setup demo account and user"
  include_context "setup system user"

  describe "validations" do
    it { is_expected.to validate_presence_of(:email) }
  end
end
