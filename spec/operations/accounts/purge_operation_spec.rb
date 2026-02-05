RSpec.describe Accounts::PurgeOperation do
  xdescribe "#call" do
    subject(:call) do
      described_class.call(account:)
    end

    include_context "setup demo account and user"
    include_context "setup system user"

    context 'when data valid ' do
      let(:account) { create(:account) }

      it 'returns successfull result' do
        expect { subject }.to change { Account.count }.by(1)
        expect(subject).to be_success
        expect(subject.success).to be_a(Account)
        expect(subject.success).to be_persisted
        # expect(subject.success).to have_attributes({ key: value })
      end
    end
  end
end
