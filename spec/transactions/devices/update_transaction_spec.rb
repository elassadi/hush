RSpec.describe Devices::UpdateTransaction do
  describe "#call" do
    subject(:call) do
      described_class.call(device_id: device.id, **device_attributes)
    end

    include_context "setup demo account and user"
    include_context "setup system user"

    let(:operation) do
      instance_double(Devices::UpdateOperation)
    end

    let(:device) { create(:device) }

    let(:device_attributes) do
      {
        device_model_id: device.device_model_id,
        device_color_id: device.device_color_id,
        imei: device.imei,
        serial_number: device.serial_number,
        unlock_pattern: device.unlock_pattern,
        unlock_pin: device.unlock_pin
      }
    end

    before do
      allow(Devices::UpdateOperation).to receive(:new)
        .with({ device:, **device_attributes })
        .and_return(operation)
    end

    context "with valid data " do
      let(:issue) { create(:issue) }

      it "returns success result" do
        expect(operation).to receive(:call).and_return(Dry::Monads::Success(issue))
        expect(call).to be_success
        expect(call.success).to eq(device)
      end
    end
  end
end
