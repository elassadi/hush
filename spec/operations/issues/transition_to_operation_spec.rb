RSpec.describe Issues::TransitionToOperation do
  include_context "setup system user"
  include_context "setup demo account and user"

  let(:issue) { create(:issue, status: :completed) }

  let(:comment) { "somecomment" }

  let(:role) { create :role, name: :demo }
  let!(:ability) do
    create(:ability, resources: %w(Issue), action_tags: %w[read create update cancel], role:)
  end

  describe "#call" do
    subject(:call) do
      described_class.call(issue:, event:, comment:, owner: demo_user)
    end

    before do
      demo_user.update(role:)
    end

    context "With non runable event" do
      let(:event) { "not_existing_event" }
      it "it return failure " do
        result = call
        expect(result).to be_failure
      end
    end

    context "With runable event" do
      let(:event) { "cancel" }
      it "it run the event and change the workflow to the new state " do
        expect do
          result = call
          expect(result).to be_success
        end.to change(issue, :status).from("completed").to("canceld")
                                     .and change(Comment, :count).by(1)
      end
    end
  end
end
