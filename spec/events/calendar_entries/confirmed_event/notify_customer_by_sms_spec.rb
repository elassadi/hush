RSpec.describe CalendarEntries::ConfirmedEvent::NotifyCustomerBySms do
  describe "#call" do
    subject(:call) do
      described_class.call(calendar_entry_id: calendar_entry.id,
                           notify_customer: true,
                           current_user_id: Current.user.id)
    end

    include_context "setup demo account and user"
    include_context "setup system user"

    let!(:application_settings) do
      create(:application_setting,
             notification_settings: {
               notification_enabled: true
             })
    end

    let(:transaction) do
      instance_double(Activities::CreateTransaction)
    end

    let(:calendar_entry) do
      create(:calendar_entry,
             calendarable: issue,
             entry_type:,
             start_at: Time.zone.now,
             end_at: 1.hour.from_now,
             category: "pause",
             status: :open,
             confirmed_at: Time.zone.now)
    end
    let(:issue) { create(:issue, assignee: Current.user) }

    let!(:notification_rule) do
      create(:customer_notification_rule,
             status: notification_rule_status,
             account: application_settings.account,
             setting: application_settings,
             template: create(:template, name: "sms_template", body: "mail_body", template_type: "sms"),
             trigger_events: %w[calendar_entry_confirmed],
             channel: 'sms')
    end

    let(:notification_rule_status) { "active" }

    before do
      allow(Activities::CreateTransaction).to receive(:call).and_return(Dry::Monads::Success(true))
      allow(Sms::CalendarEntrySimser).to receive(:call).and_return(Dry::Monads::Success(true))
    end

    context "when calendar entry type is repair or regular" do
      let(:entry_type) { 'repair' }
      it "sends an SMS and creates an activity" do
        expect(Sms::CalendarEntrySimser).to receive(:call)
          .with(calendar_entry:, template: notification_rule.template)
          .and_return(Dry::Monads::Success(true))
        expect(Activities::CreateTransaction).to receive(:call).with(
          activityable: issue,
          activity_name: :sms_sent,
          activity_data: {
            document_id: nil,
            triggering_event: :calendar_entry_confirmed,
            from: issue.status,
            to: issue.status
          },
          owner_id: Current.user.id
        ).and_return(Dry::Monads::Success(true))
        expect(call).to be_success
      end
    end

    context "when calendar entry type is not repair or regular" do
      let(:entry_type) { 'blocker' }

      it "returns a failure" do
        expect(call).to be_failure
        expect(call.failure).to eq("Calendar entry type is not repair or regular")
      end
    end

    context "when notification is not enabled" do
      let(:entry_type) { 'repair' }
      let(:notification_rule_status) { "disabled" }

      it "does not send an SMS or create an activity" do
        expect(Sms::CalendarEntrySimser).not_to receive(:call)
        expect(Activities::CreateTransaction).not_to receive(:call)
        expect(call).to be_success
      end
    end
  end
end
