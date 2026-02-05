RSpec.describe Issues::WorkflowEvents::AfterTransitionEvent::CreateActivity do
  describe "#call" do
    subject(:call) do
      described_class.call(resource_id: issue.id, resource_class: issue.class.to_s,
                           from: "draft", to: "awaiting_approval", triggering_event: "triggering_event",
                           event_args:, current_user_id: owner.id)
    end

    include_context "setup demo account and user"
    include_context "setup system user"

    let(:issue) { create(:issue, assignee: Current.user) }
    let(:role) { create(:role, name: "test") }
    let(:owner) { create(:user, account: issue.account, role:) }

    context "Activity will be created for a transition" do
      let(:notification_enabled) { false }
      let(:event_args) { { notify_customer: false } }
      it "will persist the data " do
        expect { call }.to change { Activity.count }.by(1)
        expect(call).to be_success
        expect(subject.success).to be_persisted
        expect(subject.success).to have_attributes(
          {
            activityable: issue,
            owner_id: owner.id,
            activity_name: "workflow_transition",
            activity_data: {
              event_args: { "notify_customer" => false },
              from: "draft",
              to: "awaiting_approval",
              triggering_event: "triggering_event"
            }
          }
        )
      end
    end
  end
end
