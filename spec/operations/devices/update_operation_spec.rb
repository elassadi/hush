RSpec.describe Devices::UpdateOperation do
  describe "#call" do
    subject(:call) do
      described_class.call(
        device:,
        device_model_id: new_device_model_id,
        device_color_id: new_device_color_id,
        imei: new_imei,
        serial_number:,
        unlock_pattern:,
        unlock_pin:
      )
    end

    include_context "setup demo account and user"
    include_context "setup system user"

    let(:device_model) { create(:device_model, status: :active) }
    let(:device_color) { create(:device_color, device_model:) }
    let(:device_model_id) { device_model.id }
    let(:device_color_id) { device_color.id }
    let(:imei) { Faker::Number.number(digits: 15) }
    let(:serial_number) { Faker::Number.number(digits: 10) }
    let(:unlock_pattern) { Faker::Number.number(digits: 4) }
    let(:unlock_pin) { Faker::Number.number(digits: 4) }

    let!(:device) do
      create(:device,
             device_model_id:,
             device_color_id:,
             imei:,
             serial_number:,
             unlock_pattern:,
             unlock_pin:)
    end

    context 'when data valid with an issue and changed model ' do
      let(:new_device_model) { create(:device_model, status: :active) }
      let(:new_device_color) { create(:device_color, device_model:) }
      let(:new_device_model_id) { new_device_model.id }
      let(:new_device_color_id) { device_color.id }
      let(:new_imei) { Faker::Number.number(digits: 15) }

      let!(:issue) { create(:issue, device_id: device.id) }

      before do
        allow(IssueEntries::CleanRepairSetsOperation).to receive(:call).and_return(Dry::Monads::Success(issue))
        allow(IssueEntries::AddMatchingRepairSetOperation).to receive(:call).and_return(Dry::Monads::Success(issue))
      end

      it 'returns successfull result' do
        expect { subject }.to change { Device.count }.by(0)
        expect(subject).to be_success
        expect(subject.success).to be_a(Device)
        expect(subject.success).to be_persisted
        expect(subject.success.device_model_id).to eq(new_device_model_id)
        expect(IssueEntries::CleanRepairSetsOperation).to have_received(:call).with(issue:)
        expect(IssueEntries::AddMatchingRepairSetOperation).to have_received(:call).with(issue:)
      end
    end

    context 'when data valid with an issue without changes ' do
      let(:new_device_model) { create(:device_model, status: :active) }
      let(:new_device_color) { create(:device_color, device_model:) }
      let(:new_device_model_id) { device_model.id }
      let(:new_device_color_id) { device_color.id }
      let(:new_imei) { Faker::Number.number(digits: 15) }

      let!(:issue) { create(:issue, device_id: device.id) }

      before do
        allow(IssueEntries::CleanRepairSetsOperation).to receive(:call).and_return(Dry::Monads::Success(issue))
        allow(IssueEntries::AddMatchingRepairSetOperation).to receive(:call).and_return(Dry::Monads::Success(issue))
      end

      it 'returns successfull result' do
        expect { subject }.to change { Device.count }.by(0)
        expect(subject).to be_success
        expect(subject.success).to be_a(Device)
        expect(subject.success).to be_persisted
        expect(subject.success.device_model_id).to eq(new_device_model_id)
        expect(IssueEntries::CleanRepairSetsOperation).not_to have_received(:call)
        expect(IssueEntries::AddMatchingRepairSetOperation).not_to have_received(:call)
      end
    end

    context 'when data valid with an issue with color changes ' do
      let(:new_device_model) { create(:device_model, status: :active) }
      let(:new_device_color) { create(:device_color, device_model:) }
      let(:new_device_model_id) { device_model.id }
      let(:new_device_color_id) { new_device_color.id }
      let(:new_imei) { Faker::Number.number(digits: 15) }

      let!(:issue) { create(:issue, device_id: device.id) }

      before do
        allow(IssueEntries::CleanRepairSetsOperation).to receive(:call).and_return(Dry::Monads::Success(issue))
        allow(IssueEntries::AddMatchingRepairSetOperation).to receive(:call).and_return(Dry::Monads::Success(issue))
      end

      it 'returns successfull result' do
        expect { subject }.to change { Device.count }.by(0)
        expect(subject).to be_success
        expect(subject.success).to be_a(Device)
        expect(subject.success).to be_persisted
        expect(subject.success.device_model_id).to eq(new_device_model_id)
        expect(IssueEntries::CleanRepairSetsOperation).to have_received(:call).with(issue:)
        expect(IssueEntries::AddMatchingRepairSetOperation).to have_received(:call).with(issue:)
      end
    end

    context 'when data valid with an issue with color  ' do
      let(:new_device_model) { create(:device_model, status: :active) }
      let(:new_device_color) { create(:device_color, device_model:) }
      let(:new_device_model_id) { device_model.id }
      let(:new_device_color_id) { new_device_color.id }
      let(:new_imei) { Faker::Number.number(digits: 15).to_s }

      let!(:issue) { create(:issue, device_id: device.id) }

      before do
        allow(IssueEntries::CleanRepairSetsOperation).to receive(:call).and_return(Dry::Monads::Success(issue))
        allow(IssueEntries::AddMatchingRepairSetOperation).to receive(:call).and_return(Dry::Monads::Success(issue))
      end

      it 'returns successfull result' do
        expect { subject }.to change { Device.count }.by(0)
        expect(subject).to be_success
        expect(subject.success).to be_a(Device)
        expect(subject.success).to be_persisted
        expect(subject.success.device_model_id).to eq(new_device_model_id)
        expect(subject.success.device_color_id).to eq(new_device_color_id)
        expect(subject.success.imei).to eq(new_imei)
        expect(IssueEntries::CleanRepairSetsOperation).to have_received(:call).with(issue:)
        expect(IssueEntries::AddMatchingRepairSetOperation).to have_received(:call).with(issue:)
      end
    end
  end
end
