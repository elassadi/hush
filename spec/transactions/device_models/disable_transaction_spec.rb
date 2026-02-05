RSpec.describe DeviceModels::DisableTransaction do
  describe "#call" do
    subject(:call) do
      described_class.call(device_model_id: device_model.id)
    end

    include_context "setup demo account and user"
    include_context "setup system user"

    let(:operation) do
      instance_double(DeviceModels::DisableOperation)
    end

    before do
      allow(DeviceModels::DisableOperation).to receive(:new)
        .with({ device_model: })
        .and_return(operation)
    end

    context "with valid data " do
      let(:device_model) { create(:device_model) }

      it "returns success result" do
        expect(operation).to receive(:call).and_return(Dry::Monads::Success(device_model))
        expect(call).to be_success
        expect(call.success).to eq(device_model)
      end
    end
  end
end
