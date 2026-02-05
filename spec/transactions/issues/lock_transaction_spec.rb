RSpec.describe Issues::LockTransaction do
  describe "#call" do
    subject(:call) do
      described_class.call(issue_id: issue.id)
    end

    include_context "setup demo account and user"
    include_context "setup system user"

    let(:operation) do
      instance_double(Issues::LockOperation)
    end

    before do
      allow(Issues::LockOperation).to receive(:new)
        .with({ issue:, lock_option: nil })
        .and_return(operation)
    end

    context "with valid data " do
      let(:issue) { create(:issue) }

      it "returns success result" do
        expect(operation).to receive(:call).and_return(Dry::Monads::Success(issue))
        expect(call).to be_success
        expect(call.success).to eq(issue)
      end
    end
  end
end
