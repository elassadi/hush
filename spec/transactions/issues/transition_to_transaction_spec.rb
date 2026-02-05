RSpec.describe Issues::TransitionToTransaction do
  describe "#call" do
    subject(:call) do
      described_class.call(issue_id: issue.id,
                           event: "someevent", comment: "somecomment",
                           owner: system_user)
    end

    include_context "setup system user"
    include_context "setup demo account and user"

    let(:operation) do
      instance_double(Issues::TransitionToOperation)
    end

    before do
      allow(Issues::TransitionToOperation).to receive(:new).and_return(operation)
    end

    context "with valid status" do
      let(:issue) { create(:issue) }

      it "returns success result" do
        expect(operation).to receive(:call).and_return(Dry::Monads::Success(issue))
        expect(call).to be_success
        expect(call.success).to eq(issue)
      end
    end
  end
end
