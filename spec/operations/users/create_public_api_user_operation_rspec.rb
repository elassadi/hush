RSpec.describe Users::CreatePublicApiUserOperation do
  describe "#call" do
    subject(:call) do
      described_class.call(account:)
    end

    include_context "setup demo account and user"
    include_context "setup system user"

    let(:account) { create(:account) }
    let!(:role) { create(:role, name: :public_api, account:) }

    context 'when data is valid' do
      it 'returns a successful result' do
        expect do
          expect(Event).to receive(:broadcast).with(:api_token_created, any_args)
          expect(Event).to receive(:broadcast).with(:public_api_user_created, any_args)
          expect(Event).to receive(:broadcast).with(:user_created, any_args)
          expect(call).to(be_success)
        end.to(
          change(ApiToken, :count).by(1).and(
            change(User, :count).by(1)
          )
        )
      end
    end

    context 'when a public_api user exists already' do
      let!(:user) { create(:user, account:, role:) }
      it 'returns a failure result' do
        expect do
          expect(call).to(be_failure)
        end.to(
          change(ApiToken, :count).by(0).and(
            change(User, :count).by(0)
          )
        )
      end
    end
  end
end
