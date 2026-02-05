RSpec.shared_context "setup demo account and user" do
  # let!(:demo_account) { create(:DEMO_ACCOUNT) }
  let!(:demo_user) { create(:user, :demo_user, account: Account.recloud, master: true) }
  before do
    Current.user = demo_user
  end
end
