RSpec.describe PurchaseOrders::SyncBySupplierSourceOperation do
  describe "#call" do
    subject(:call) do
      described_class.call(supplier_source:)
    end

    include_context "setup demo account and user"
    include_context "setup system user"

    context 'with existing purchase orders' do
      let(:issue) do
        create(:issue, assignee: Current.user,
                       status_category: :in_progress, status: "awaiting_device")
      end
      let(:article) { create(:article) }
      let(:issue_entry) { create(:issue_entry, issue:, article:, qty: 1, price: 10) }
      let(:stock_reservation) do
        create(:stock_reservation,
               article:, qty: 1, originator: issue_entry,
               prio: StockReservation::PRIO_NORMAL)
      end

      let!(:existing_supplier_source) do
        create(:supplier_source, article:,
                                 stock_status: :available)
      end
      let!(:open_purchase_order) do
        create(:purchase_order, status: :open,
                                supplier: existing_supplier_source.supplier)
      end
      let!(:purchase_order_entry) do
        create(:purchase_order_entry, purchase_order: open_purchase_order, article:,
                                      originator: stock_reservation)
      end

      let(:new_supplier) { create(:supplier) }
      let!(:supplier_source) do
        create(:supplier_source, article:, favorite: true,
                                 supplier: new_supplier,
                                 stock_status: :available)
      end
      before do
        article.stock.update!(in_stock_available: -1)
      end

      it 'delete the old purchase entry create a new one with a new purchase_order_entry for the new supplier' do
        expect { subject }.to change { PurchaseOrder.count }.by(0)
        expect { open_purchase_order.reload }.to raise_error(ActiveRecord::RecordNotFound)
        new_purchase_order = PurchaseOrder.last
        expect(new_purchase_order.supplier).to eq(supplier_source.supplier)
      end
    end

    context 'with existing purchase orders' do
      let(:issue) do
        create(:issue, assignee: Current.user,
                       status_category: :in_progress, status: "awaiting_device")
      end
      let(:article) { create(:article) }
      let(:issue_entry) { create(:issue_entry, issue:, article:, qty: 1, price: 10) }
      let(:stock_reservation) do
        create(:stock_reservation,
               article:, qty: 1, originator: issue_entry,
               prio: StockReservation::PRIO_NORMAL)
      end

      let!(:existing_supplier_source) do
        create(:supplier_source, article:,
                                 stock_status: :available)
      end
      let!(:open_purchase_order) do
        create(:purchase_order, status: :open,
                                supplier: existing_supplier_source.supplier)
      end
      let!(:purchase_order_entry) do
        create(:purchase_order_entry, purchase_order: open_purchase_order, article:,
                                      originator: stock_reservation)
      end

      let(:new_supplier) { create(:supplier) }
      let!(:supplier_source) do
        create(:supplier_source, article:, favorite: true,
                                 supplier: new_supplier,
                                 stock_status: :available)
      end

      let(:article2) { create(:article) }
      let(:issue_entry2) { create(:issue_entry, issue:, article: article2, qty: 1, price: 20) }
      let(:stock_reservation2) do
        create(:stock_reservation,
               article: article2, qty: 1, originator: issue_entry2,
               prio: StockReservation::PRIO_NORMAL)
      end

      let!(:existing_supplier_source2) do
        create(:supplier_source, article: article2,
                                 stock_status: :available)
      end

      let!(:purchase_order_entry2) do
        create(:purchase_order_entry, purchase_order: open_purchase_order, article: article2,
                                      originator: stock_reservation2)
      end

      before do
        supplier_id = supplier_source.sorted_supplier_sources.first.supplier_id
        article.update(supplier_id:)

        article.stock.update!(in_stock_available: -1)
      end

      it 'doesnt delete old purchase entry create a new one with a new purchase_order_entry for the new supplier' do
        expect { subject }.to change { PurchaseOrder.count }.by(1)
        expect { open_purchase_order.reload }.not_to raise_error
        new_purchase_order = PurchaseOrder.last
        expect(new_purchase_order.supplier).to eq(supplier_source.supplier)
      end
    end
  end
end
