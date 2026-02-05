RSpec.describe Activities::CreateOperation do
  describe "#call" do
    subject(:call) do
      described_class.call(
        activityable: issue, activity_name: "activity_name", activity_data: {}, owner_id: demo_user.id
      )
    end

    include_context "setup demo account and user"
    include_context "setup system user"

    context 'when data valid ' do
      let(:issue) { create(:issue) }

      it 'returns successfull result' do
        allow(Event).to receive(:broadcast)
        expect { subject }.to change { Activity.count }.by(1)
        expect(subject).to be_success
        expect(subject.success).to be_a(Activity)
        expect(subject.success).to be_persisted
        expect(Event).to have_received(:broadcast).with(:activity_created,
                                                        activity_id: subject.success.id)
        # expect(subject.success).to have_attributes({ key: value })
      end
    end
  end
end
