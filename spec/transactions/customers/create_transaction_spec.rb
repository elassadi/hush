RSpec.describe Customers::CreateTransaction do
  describe "#call" do
    subject(:call) do
      described_class.call(
        attributes: {
          salutation:, first_name:, last_name:, company_name:,
          street:, house_number:, city:, country:, post_code:, email:, phone_number:, mobile_number:
        }
      )
    end

    let(:salutation) { "Mr" }
    let(:first_name) { "John" }
    let(:last_name) { "Doe" }
    let(:company_name) { "ACME" }
    let(:street) { "Main Street" }
    let(:house_number) { "1" }
    let(:city) { "Springfield" }
    let(:country) { "USA" }
    let(:post_code) { "12345" }
    let(:email) { "somemail@mail.de" }
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

    include_context "setup demo account and user"
    include_context "setup system user"

    let(:operation) do
      instance_double(Customers::CreateOperation)
    end

    before do
      allow(Customers::CreateOperation).to receive(:new)
        .with({ attributes: })
        .and_return(operation)
    end

    context "with valid data " do
      let(:customer) { create(:customer) }

      it "returns success result" do
        expect(operation).to receive(:call).and_return(Dry::Monads::Success(customer))
        expect(call).to be_success
        # expect(call.success).to eq(customer)
      end
    end
  end
end
