RSpec.describe Devices::CreateOperation do
  describe "#call" do
    subject(:call) do
      described_class.call(
        device_model_id:,
        device_color_id:,
        imei:,
        serial_number:,
        unlock_pattern:,
        unlock_pin:
      )
    end

    include_context "setup demo account and user"
    include_context "setup system user"

    context 'when data valid ' do
      let(:device_model) { create(:device_model, status: :active) }
      let(:device_color) { create(:device_color, device_model:) }
      let(:device_model_id) { device_model.id }
      let(:device_color_id) { device_color.id }
      let(:imei) { Faker::Number.number(digits: 15) }
      let(:serial_number) { Faker::Number.number(digits: 10) }
      let(:unlock_pattern) { Faker::Number.number(digits: 4) }
      let(:unlock_pin) { Faker::Number.number(digits: 4) }

      it 'returns successfull result' do
        expect { subject }.to change { Device.count }.by(1)
        expect(subject).to be_success
        expect(subject.success).to be_a(Device)
        expect(subject.success).to be_persisted
      end
    end

    context 'when data are not valid or missing' do
      let(:device_model) { create(:device_model, status: :active) }
      let(:device_model_id) { device_model.id }
      let(:device_color_id) { nil }
      let(:imei) { Faker::Number.number(digits: 15) }
      let(:serial_number) { Faker::Number.number(digits: 10) }
      let(:unlock_pattern) { Faker::Number.number(digits: 4) }
      let(:unlock_pin) { Faker::Number.number(digits: 4) }

      it 'returns successfull result' do
        expect { subject }.to change { Device.count }.by(0)
        expect(subject).to be_failure
      end
    end

    context 'when imei is missing ' do
      let(:device_model) { create(:device_model, status: :active) }
      let(:device_color) { create(:device_color, device_model:) }
      let(:device_model_id) { device_model.id }
      let(:device_color_id) { device_color.id }
      let(:imei) { nil }
      let(:serial_number) { Faker::Number.number(digits: 10) }
      let(:unlock_pattern) { Faker::Number.number(digits: 4) }
      let(:unlock_pin) { Faker::Number.number(digits: 4) }

      it 'returns successfull result' do
        expect { subject }.to change { Device.count }.by(1)
        expect(subject).to be_success
        expect(subject.success).to be_a(Device)
        expect(subject.success).to be_persisted
      end
    end

    context 'when imei and serien nummber are missing ' do
      let(:device_model) { create(:device_model, status: :active) }
      let(:device_color) { create(:device_color, device_model:) }
      let(:device_model_id) { device_model.id }
      let(:device_color_id) { device_color.id }
      let(:imei) { nil }
      let(:serial_number) { nil }
      let(:unlock_pattern) { Faker::Number.number(digits: 4) }
      let(:unlock_pin) { Faker::Number.number(digits: 4) }

      it 'returns successfull result' do
        expect { subject }.to change { Device.count }.by(0)
        expect(subject).to be_failure
      end
    end
  end
end
