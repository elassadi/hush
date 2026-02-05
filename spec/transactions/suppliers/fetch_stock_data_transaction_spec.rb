RSpec.describe Suppliers::FetchStockDataTransaction do
  describe "#call" do
    subject(:call) do
      described_class.call(supplier_id: supplier.id)
    end

    include_context "setup system user"
    include_context "setup demo account and user"

    let(:operation) do
      instance_double(Suppliers::FetchStockDataOperation)
    end

    before do
      allow(Suppliers::FetchStockDataOperation).to receive(:new).and_return(operation)
    end

    context "with supplier data" do
      let(:supplier) { create(:supplier) }

      it "returns success result" do
        expect(operation).to receive(:call).and_return(Dry::Monads::Success(true))
        expect(call).to be_success
        expect(call.success).to eq(true)
      end
    end
  end
end
