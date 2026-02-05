RSpec.describe Issues::KvaPrintedEvent::NotifyUserBySms do
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
    let(:document) { create(:document, documentable: issue) }
    # let(:article) { create(:article) }
    # let(:issue_entry) { create(:issue_entry, issue:, article:, qty: 1, price: 10) }
    # let(:stock_reservation) { create(:stock_reservation, article:, qty: 1, originator: issue_entry) }

    before do
      allow(Sms::IssueSimser).to receive(:new).and_return(send_sms)
    end

    context "When event issue_order_print is create and notification rule are set " do
      let(:notification_enabled) { true }
      it "will not send an sms" do
        expect(send_sms).not_to receive(:call)
        expect(call).to be_success
      end
    end

    context "When event issue_order_print is create and notification rule are set " do
      let(:notification_enabled) { false }
      let!(:notification_rule) do
        create(:customer_notification_rule,
               account: application_settings.account,
               setting: application_settings,
               template: create(:template, name: "sms_template", body: "sms_body", template_type: "sms"),
               trigger_events: %w[issue_kva_printed],
               channel: 'sms')
      end
      it "will not send an sms" do
        expect(send_sms).not_to receive(:call)
        expect(call).to be_success
      end
    end

    context "When event issue_order_print is create and notification rule are set " do
      let(:notification_enabled) { true }
      let!(:notification_rule) do
        create(:customer_notification_rule,
               account: application_settings.account,
               setting: application_settings,
               template: create(:template, name: "sms_template", body: "sms_body", template_type: "sms"),
               trigger_events: %w[issue_kva_printed],
               channel: 'sms')
      end
      it "calls the CreateStockReservationTransaction " do
        expect(send_sms).to receive(:call).and_return(Dry::Monads::Success(true))
        expect(call).to be_success
        # expect(call.success).to eq(stock_reservation)
      end
    end
  end
end
