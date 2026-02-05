RSpec.describe Issues::UpdateTransaction do
  describe "#call" do
    subject(:call) do
      described_class.call(issue_id: issue.id, issue_attributes:)
    end

    include_context "setup demo account and user"
    include_context "setup system user"

    let(:operation) do
      instance_double(Issues::UpdateOperation)
    end

    let(:issue_attributes) do
      {
        title: "new title",
        description: "new description",
        status: "new status"
      }
    end

    before do
      allow(Issues::UpdateOperation).to receive(:new)
        .with({ issue:, **issue_attributes })
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
