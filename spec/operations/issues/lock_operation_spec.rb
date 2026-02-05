RSpec.describe Issues::LockOperation do
  describe "#call" do
    subject(:call) do
      described_class.call(issue:, lock_option:)
    end

    include_context "setup demo account and user"
    include_context "setup system user"

    context 'when data valid ' do
      let(:issue) { create(:issue) }
      let(:lock_option) { :temporary }

      it 'returns successfull result' do
        expect(subject).to be_success
        Issues::UnlockJob.perform_now
        issue.reload

        expect(subject.success).to be_a(Issue)
        expect(subject.success).to be_locked
        expect(subject.success).to be_persisted
        # expect(subject.success).to have_attributes({ key: value })
      end
    end

    context 'when lock expires' do
      let(:issue) { create(:issue) }
      let(:lock_option) { :temporary }

      it 'expires the lock and unlocks the issue' do
        # Reload the issue to trigger the unlock check
        expect(subject).to be_success
        issue.reload
        issue.update_column(:updated_at, 20.minutes.ago) # Simulate that the issue was locked 20 minutes ago

        Issues::UnlockJob.perform_now

        # Reload the issue to reflect any changes made by the job
        issue.reload

        # Call the lock check, which should trigger the expiration
        expect(issue.locked?).to be_falsey
        expect(issue.unlocked_at).to be_present
      end
    end

    context 'when lock is permanent' do
      let(:issue) { create(:issue) }
      let(:lock_option) { :permanent }

      it 'expires the lock and unlocks the issue' do
        # Reload the issue to trigger the unlock check
        expect(subject).to be_success
        Issues::UnlockJob.perform_now
        issue.reload

        issue.update_column(:updated_at, 20.minutes.ago) # Simulate that the issue was locked 20 minutes ago

        # Call the lock check, which should trigger the expiration
        expect(issue.locked?).to be_truthy
        expect(issue.unlocked_at).to be_blank
      end
    end
  end
end
