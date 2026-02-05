RSpec.describe PurchaseOrders::StockOrderOperation do
  describe "#call" do
    subject(:call) do
      described_class.call(purchase_order:)
    end

    include_context "setup system user"
    include_context "setup demo account and user"

    let(:article) { create(:article) }
    let(:issue) { create(:issue, status_category: :in_progress) }
    let!(:issue_entry) do
      issue_entry = create(:issue_entry, issue:, article:, qty: 1, price: 10)
      IssueEntries::CreateStockReservationOperation.call(issue_entry:)
      StockReservations::SyncOperation.call(article: article.reload)
    end

    let(:stock_location) { create(:stock_location) }
    let(:stock_area) { create(:stock_area, stock_location:) }
    let(:stock_reservation) { StockReservation.last }

    let!(:supplier_source) { create(:supplier_source, article:) }
    let!(:stock_item) { create(:stock_item, article:, stock_area:) }

    context 'when status is not done' do
      let!(:purchase_order) do
        create(:purchase_order,
               supplier: article.supplier,
               status_category: :open,
               purchase_order_entries: [build(:purchase_order_entry, article:, qty: 1, price: 10)])
      end
      it 'returns successfull result without creating purchase order and increase count of entries' do
        expect(subject).to be_failure
        expect(subject.failure).to eq(
          "#{described_class} failed: Purchase order is not in progress status id: #{purchase_order.id}"
        )
      end
    end

    context 'when all conditions are met and a purchase order exists' do
      let!(:purchase_order) do
        create(:purchase_order,
               supplier: article.supplier,
               status_category: :in_progress,
               purchase_order_entries: [build(:purchase_order_entry, article:, qty: 1, price: 10)])
      end
      it 'returns successfull result without creating purchase order and increase count of entries' do
        allow(Event).to receive(:broadcast)
        expect { subject }.to change { StockMovement.count }.by(1)
        expect(subject).to be_success
        expect(Event).to have_received(:broadcast).with(
          :stock_movement_created,
          { stock_movement_id: StockMovement.last.id }
        )
      end
    end
  end
end
