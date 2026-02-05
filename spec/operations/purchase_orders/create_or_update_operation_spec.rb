RSpec.describe PurchaseOrders::CreateOrUpdateOperation do
  describe "#call" do
    subject(:call) do
      described_class.call(stock_reservation:)
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

    # let(:stock_reservation) {
    #   create(:stock_reservation, qty: 1, article: article.reload, originator: issue_entry,
    #     prio: StockReservation::PRIO_NORMAL
    #   )
    # }

    # let!(:stock_movement) do
    #   sm = create(:stock_movement, article:, stock_location:, stock_area:, qty: 1, action: :stock_out)
    #   Stocks::StockMovements::CreatedEvent::StockInOut.call(stock_movement_id: sm.id)
    # end

    let!(:supplier_source) { create(:supplier_source, article:) }

    context 'when all conditions are met ' do
      it 'returns successfull result and create purchase order' do
        expect { subject }.to change { PurchaseOrder.count }.by(1)
        expect(subject).to be_success
        expect(call.success).to eq(PurchaseOrder.last)
        expect(call.success.purchase_order_entries.count).to eq(1)
        expect(call.success.purchase_order_entries).to include(PurchaseOrderEntry.last)
      end
    end

    context 'when all conditions are met and a purchase prder exists' do
      let!(:purchase_order) do
        create(:purchase_order,
               supplier: article.supplier,
               purchase_order_entries: [build(:purchase_order_entry, article:, qty: 1, price: 10)])
      end
      it 'returns successfull result without creating purchase order and increase count of entries' do
        expect { subject }.to change { PurchaseOrder.count }.by(0)
        expect(subject).to be_success
        expect(call.success).to eq(PurchaseOrder.last)
        expect(call.success.purchase_order_entries.count).to eq(2)
        expect(call.success.purchase_order_entries).to include(PurchaseOrderEntry.last)
      end
    end

    context 'when stock is available' do
      let!(:stock_movement) do
        sm = create(:stock_movement, article:, stock_location:, stock_area:, qty: 1)
        Stocks::StockMovements::CreatedEvent::StockInOut.call(stock_movement_id: sm.id)
      end
      it 'wont create a purchase order' do
        expect { subject }.to change { PurchaseOrder.count }.by(0)
        expect(subject).to be_success
      end
    end

    context 'when supplier source is missing' do
      let!(:supplier_source) { nil }
      it 'wont create a purchase order' do
        expect { subject }.to change { PurchaseOrder.count }.by(0)
        expect(subject).to be_success
      end
    end

    context 'when issue ist not in progress' do
      let(:issue) { create(:issue, status_category: :open) }
      it 'wont create a purchase order' do
        expect { subject }.to change { PurchaseOrder.count }.by(0)
        expect(subject).to be_success
      end
    end
  end
end
