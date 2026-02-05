RSpec.describe Activities::CreateTransaction do
  describe "#call" do
    subject(:call) do
      described_class.call(activityable: issue,
                           activity_name: "activity_name", activity_data: {},
                           owner_id: demo_user.id)
    end

    include_context "setup demo account and user"
    include_context "setup system user"

    let(:operation) do
      instance_double(Activities::CreateOperation)
    end

    before do
      allow(Activities::CreateOperation).to receive(:new)
        .with({ activityable: issue, activity_name: "activity_name", activity_data: {}, owner_id: demo_user.id })
        .and_return(operation)
    end

    context "with valid data " do
      let(:issue) { create(:issue) }
      let(:activity) { create(:activity, activityable: issue) }

      it "returns success result" do
        expect(operation).to receive(:call).and_return(Dry::Monads::Success(activity))
        expect(call).to be_success
        expect(call.success).to eq(activity)
      end
    end
  end
end
