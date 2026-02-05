RSpec.describe Users::CreateApiTokenOperation do
  describe "#call" do
    subject(:call) do
      described_class.call(user:)
    end

    include_context "setup demo account and user"
    include_context "setup system user"

    let(:user) { create(:user) }

    context 'when data is valid' do
      it 'returns a successful result' do
        expect do
          expect(Event).to receive(:broadcast).with(:api_token_created, api_token_id: anything)
          expect(call).to(be_success)
        end.to(
          change(ApiToken, :count).by(1)
        )
      end

      it 'deletes any existing API token and creates a new active one' do
        existing_token = user.api_tokens.create!(status: :active, account: user.account)

        expect do
          call
        end.to change { user.api_tokens.where(status: :deleted).count }.by(1)

        expect(existing_token.reload.status).to eq("deleted")
      end
    end
  end
end
