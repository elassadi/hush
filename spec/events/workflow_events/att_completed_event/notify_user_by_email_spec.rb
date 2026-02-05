RSpec.describe Issues::WorkflowEvents::AttCompletedEvent::NotifyUserByEmail do
  describe "#call" do
    subject(:call) do
      described_class.call(resource_id: issue.id, resource_class: issue.class.to_s,
                           from: "repairing_successfull", to: "completed", triggering_event: "complete",
                           event_args:, current_user_id: owner.id)
    end

    include_context "setup demo account and user"
    include_context "setup system user"

    let!(:application_settings) do
      create(:application_setting,
             notification_settings: {
               notification_enabled:
             })
    end

    let(:role) { create(:role, name: "test") }
    let(:owner) { create(:user, account: issue.account, role:) }

    let(:deliver_email) do
      instance_double("ActionMailer::MessageDelivery", deliver_now: true)
    end

    before do
      allow(IssueMailer).to receive(:call).and_return(deliver_email)
    end

    let(:issue) { create(:issue, assignee: Current.user) }
    let(:document) { create(:document, documentable: issue) }

    context "When event issue_order_print is create and notification rule are set " do
      let(:notification_enabled) { true }
      let(:event_args) { { notify_customer: false } }
      it "will not send an sms" do
        expect(deliver_email).not_to receive(:deliver_now)
        expect(call).to be_success
      end
    end

    context "When event issue_order_print is create and notification rule are set " do
      let(:notification_enabled) { false }
      let(:event_args) { { notify_customer: false } }
      let!(:notification_rule) do
        create(:customer_notification_rule,
               account: application_settings.account,
               setting: application_settings,
               template: create(:template, name: "mail_template", body: "mail_body", template_type: "mail"),
               trigger_events: %w[issue_completed],
               channel: 'mail')
      end
      it "will not send an sms" do
        expect(deliver_email).not_to receive(:deliver_now)
        expect(call).to be_success
      end
    end

    context "When event issue_order_print is create and notification rule are set " do
      let(:notification_enabled) { true }
      let(:event_args) { { notify_customer: true } }
      let!(:notification_rule) do
        create(:customer_notification_rule,
               account: application_settings.account,
               setting: application_settings,
               template: create(:template, name: "mail_template", body: "mail_body", template_type: "mail"),
               trigger_events: %w[issue_completed],
               channel: 'mail')
      end
      it "calls the CreateStockReservationTransaction " do
        expect(deliver_email).to receive(:deliver_now).and_return(true)
        expect(call).to be_success
        expect(Activity.last).to have_attributes(
          {
            activityable: issue,
            owner_id: owner.id,
            activity_name: "email_sent",
            activity_data: {
              document_id: nil,
              from: "repairing_successfull",
              to: "completed",
              triggering_event: "complete"
            }
          }
        )
      end
    end
  end
end
