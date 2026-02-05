RSpec.describe DeviceModels::DisableOperation do
  describe "#call" do
    subject(:call) do
      described_class.call(device_model:)
    end

    include_context "setup demo account and user"
    include_context "setup system user"

    context 'when data valid ' do
      let(:device_model) { create(:device_model, status: :active) }

      it 'returns successfull result' do
        expect { subject }.to change { DeviceModel.count }.by(1)
        expect(subject).to be_success
        expect(subject.success).to be_a(DeviceModel)
        expect(subject.success).to be_status_disabled
      end
    end
  end
end
