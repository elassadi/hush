RSpec.describe Issues::WorkflowEvents::AttRepairingUnsuccessfullEvent::NotifyUserBySms do
  describe "#call" do
    subject(:call) do
      described_class.call(resource_id: issue.id, resource_class: issue.class.to_s,
                           from: "repairing", to: "repairing_unsuccessfull", triggering_event: "triggering_event",
                           event_args:, current_user_id: owner.id)
    end

    include_context "setup demo account and user"
    include_context "setup system user"

    let(:role) { create(:role, name: "test") }
    let(:owner) { create(:user, account: issue.account, role:) }

    let!(:application_settings) do
      create(:application_setting,
             notification_settings: {
               notification_enabled:
             },
             sms_settings: {
               sms_enabled: true,
               sms_provider: "sms_provider",
               sms_username: "sms_username",
               sms_password: "sms_password"
             })
    end

    let(:send_sms) do
      instance_double(Sms::IssueSimser)
    end

    let(:issue) { create(:issue, assignee: Current.user) }

    before do
      allow(Sms::IssueSimser).to receive(:new).and_return(send_sms)
    end

    context "When event issue_order_print is create and notification rule are set " do
      let(:notification_enabled) { true }
      let(:event_args) { { notify_customer: false } }
      it "will not send an sms" do
        expect(send_sms).not_to receive(:call)
        expect(call).to be_success
      end
    end

    context "When event issue_order_print is create and notification rule are set " do
      let(:notification_enabled) { false }
      let(:event_args) { { notify_customer: true } }
      let!(:notification_rule) do
        create(:customer_notification_rule,
               account: application_settings.account,
               setting: application_settings,
               template: create(:template, name: "sms_template", body: "sms_body", template_type: "sms"),
               trigger_events: %w[issue_repairing_unsuccessfull],
               channel: 'sms')
      end
      it "will not send an sms" do
        expect(send_sms).not_to receive(:call)
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
               template: create(:template, name: "sms_template", body: "sms_body", template_type: "sms"),
               trigger_events: %w[issue_repairing_unsuccessfull],
               channel: 'sms')
      end
      it "calls the CreateStockReservationTransaction " do
        expect(send_sms).to receive(:call).and_return(Dry::Monads::Success(true))
        expect(call).to be_success
        expect(Activity.last).to have_attributes(
          {
            activityable: issue,
            owner_id: owner.id,
            activity_name: "sms_sent",
            activity_data: {
              document_id: nil,
              from: "repairing",
              to: "repairing_unsuccessfull",
              triggering_event: "triggering_event"
            }
          }
        )
        # expect(call.success).to eq(stock_reservation)
      end
    end
  end
end
