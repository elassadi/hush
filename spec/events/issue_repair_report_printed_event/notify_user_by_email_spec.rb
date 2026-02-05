RSpec.describe Issues::IssueRepairReportPrintedEvent::NotifyUserByEmail do
  describe "#call" do
    subject(:call) do
      described_class.call(document_id: document.id, notify_customer: true, current_user_id: Current.user.id)
    end

    include_context "setup demo account and user"
    include_context "setup system user"

    let!(:application_settings) do
      create(:application_setting,
             notification_settings: {
               notification_enabled:
             })
    end

    let(:deliver_email) do
      instance_double("ActionMailer::MessageDelivery", deliver_now: true)
    end

    before do
      allow(IssueMailer).to receive(:call).and_return(deliver_email)
    end

    let(:issue) { create(:issue, assignee: Current.user) }
    let(:document) { create(:document, documentable: issue) }

    context "When event repair_report_printed is create and notification rule are set " do
      let(:notification_enabled) { true }
      it "will not send an sms" do
        expect(deliver_email).not_to receive(:deliver_now)
        expect(call).to be_success
      end
    end

    context "When event repair_report_printed is create and notification rule are set " do
      let(:notification_enabled) { false }
      let!(:notification_rule) do
        create(:customer_notification_rule,
               account: application_settings.account,
               setting: application_settings,
               template: create(:template, name: "mail_template", body: "mail_body", template_type: "mail"),
               trigger_events: %w[issue_repairing_successfull issue_repairing_unsuccessfull],
               channel: 'mail')
      end
      it "will not send an sms" do
        expect(deliver_email).not_to receive(:deliver_now)
        expect(call).to be_success
      end
    end

    context "When event repair_report_printed is create and notification rule are set " do
      let(:notification_enabled) { true }
      let!(:notification_rule) do
        create(:customer_notification_rule,
               account: application_settings.account,
               setting: application_settings,
               template: create(:template, name: "mail_template", body: "mail_body", template_type: "mail"),
               trigger_events: %w[issue_repairing_unsuccessfull issue_repairing_successfull],
               channel: 'mail')
      end
      it "calls the CreateStockReservationTransaction " do
        expect(deliver_email).to receive(:deliver_now).and_return(true)
        expect(call).to be_success
      end
    end
  end
end
