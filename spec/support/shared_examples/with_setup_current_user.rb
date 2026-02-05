RSpec.shared_context "setup system user" do
  let!(:recloud_account) { create(:RECLOUD_ACCOUNT) }
  let!(:system_user) { create(:user, :system_user, account: recloud_account) }
end
