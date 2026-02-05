RSpec.describe Customers::CreateOperation do
  describe "#call" do
    subject(:call) do
      described_class.call(attributes:)
    end

    include_context "setup demo account and user"
    include_context "setup system user"

    let(:salutation) { "male" }
    let(:first_name) { "John" }
    let(:last_name) { "Doe" }
    let(:company_name) { "ACME" }
    let(:street) { "Main Street" }
    let(:house_number) { "1" }
    let(:city) { "Springfield" }
    let(:country) { "USA" }
    let(:post_code) { "12345" }
    let(:phone_number) { "123456789" }
    let(:mobile_number) { "987654321" }

    let(:attributes) do
      {
        salutation:,
        first_name:,
        last_name:,
        company_name:,
        street:,
        house_number:,
        city:,
        country:,
        post_code:,
        email:,
        phone_number:,
        mobile_number:
      }
    end

    context 'when data valid' do
      let(:email) { Faker::Internet.unique.email }
      it 'returns successfull result' do
        expect { subject }.to change { Customer.count }.by(1).and change { Address.count }.by(1)
        expect(subject).to be_success
        expect(subject.success).to be_a(Customer)
        expect(subject.success).to be_persisted
        # expect(subject.success).to have_attributes({ key: value })
      end
    end

    context 'when customer data are missing' do
      let(:first_name) { "" }
      let(:email) { Faker::Internet.unique.email }
      it 'returns successfull result' do
        expect { subject }.to change { Customer.count }.by(0).and change { Address.count }.by(0)
        expect(subject).to be_failure
        expect(subject.failure.full_messages.join).to eq("Vorname muss ausgefüllt werden")
      end
    end

    context 'when customer data are missing' do
      let(:street) { "" }
      let(:email) { Faker::Internet.unique.email }
      it 'returns successfull result' do
        expect(subject).to be_failure
        expect(subject.failure.full_messages.join).to eq("Straße muss ausgefüllt werden")
      end
    end
  end
end
