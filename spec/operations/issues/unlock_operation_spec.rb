RSpec.describe Issues::UnlockOperation do
  describe "#call" do
    subject(:call) do
      described_class.call(issue:)
    end

    include_context "setup demo account and user"
    include_context "setup system user"

    context 'when data valid ' do
      let(:issue) { create(:issue) }

      before do
        issue.apply_lock!(lock_option: :temporary)
      end

      it 'returns successfull result' do
        expect(subject).to be_success
        expect(subject.success).to be_a(Issue)
        expect(subject.success).not_to be_locked
        expect(issue.locked?).to be_falsey
        expect(issue.unlocked_at).to be_present
      end
    end
  end
end
