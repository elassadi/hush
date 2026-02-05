RSpec.describe PurchaseOrders::SplitOperation do
  describe "#call" do
    subject(:call) do
      described_class.call(purchase_order: src_purchase_order, entry_quantities:, stock_immediately:)
    end

    include_context "setup demo account and user"
    include_context "setup system user"

    let(:stock_immediately) { true }

    let(:stock_location) { create(:stock_location) }
    let(:stock_area) { create(:stock_area, stock_location:) }
    let(:supplier) { create(:supplier) }

    let(:article_pos1) { create(:article) }
    let(:article_pos2) { create(:article) }

    let!(:supplier_source1) { create(:supplier_source, article: article_pos1, supplier:) }
    let!(:stock_item1) { create(:stock_item, article: article_pos1, stock_area:) }

    let!(:supplier_source2) { create(:supplier_source, article: article_pos2, supplier:) }
    let!(:stock_item2) { create(:stock_item, article: article_pos2, stock_area:) }

    before do
      allow(Current.user).to receive(:can?).with(anything, anything).and_return(true)
    end

    context 'purchase order has wrong status' do
      let!(:src_purchase_order) { create(:purchase_order, status: :draft) }
      let(:entry_quantities) { [{ id: 1, qty: 1 }] }

      it 'returns failure result' do
        expect { subject }.to change { PurchaseOrder.count }.by(0)
        expect(subject).to be_failure
        # expect(subject.success).to have_attributes({ key: value })
      end
    end

    context 'Split an order with 1 product all the qty' do
      let!(:issue) { create(:issue, status_category: :in_progress, status: :ordered) }
      let!(:issue_entry1) do
        issue_entry1 = create(:issue_entry, issue:, article: article_pos1, qty: 2, price: 10)
        IssueEntries::CreateStockReservationOperation.call(issue_entry: issue_entry1)
        StockReservations::SyncOperation.call(article: article_pos1.reload)
        issue_entry1
      end

      let!(:stock_reservation1) do
        stock_reservation = IssueEntries::CreateStockReservationOperation.call(issue_entry: issue_entry1).success
        StockReservations::SyncOperation.call(article: article_pos1.reload)
        stock_reservation
      end

      let!(:issue_entry2) do
        create(:issue_entry, issue:, article: article_pos2, qty: 2, price: 20)
      end

      let!(:stock_reservation2) do
        stock_reservation = IssueEntries::CreateStockReservationOperation.call(issue_entry: issue_entry2).success
        StockReservations::SyncOperation.call(article: article_pos2.reload)
        stock_reservation
      end

      let!(:src_purchase_order) do
        create(:purchase_order,
               supplier:,
               status_category: :open,
               status: :ordered,
               purchase_order_entries: [
                 build(:purchase_order_entry, article: article_pos1, qty: 2, price: 10,
                                              originator: stock_reservation1),
                 build(:purchase_order_entry, article: article_pos2, qty: 2, price: 20,
                                              originator: stock_reservation2)
               ])
      end

      let!(:entry_quantities) { [{ id: src_purchase_order.purchase_order_entries.first.id, qty: 2 }] }

      it 'returns successfull result' do
        expect { subject }.to change { PurchaseOrder.count }.by(1)
        expect { subject }.to change { PurchaseOrderEntry.count }.by(0)
        expect(subject).to be_success
        expect(subject.success).to be_a(PurchaseOrder)
        expect(subject.success).to be_persisted
        expect(subject.success.linked_to_id).to eq(src_purchase_order.id)
        expect(subject.success.status_delivered?).to be_truthy
        expect(subject.success.purchase_order_entries.count).to eq(1)
        expect(subject.success.purchase_order_entries.first.qty).to eq(2)
        expect(subject.success.purchase_order_entries.first.price).to eq(10)
        expect(src_purchase_order.purchase_order_entries.count).to eq(1)
      end
    end

    context 'Split an order with 2 entries each with 1 qty less' do
      let!(:issue) { create(:issue, status_category: :in_progress, status: :ordered) }
      let!(:issue_entry1) do
        issue_entry1 = create(:issue_entry, issue:, article: article_pos1, qty: 2, price: 10)
        IssueEntries::CreateStockReservationOperation.call(issue_entry: issue_entry1)
        StockReservations::SyncOperation.call(article: article_pos1.reload)
        issue_entry1
      end

      let!(:stock_reservation1) do
        stock_reservation = IssueEntries::CreateStockReservationOperation.call(issue_entry: issue_entry1).success
        StockReservations::SyncOperation.call(article: article_pos1.reload)
        stock_reservation
      end

      let!(:issue_entry2) do
        create(:issue_entry, issue:, article: article_pos2, qty: 2, price: 20)
      end

      let!(:stock_reservation2) do
        stock_reservation = IssueEntries::CreateStockReservationOperation.call(issue_entry: issue_entry2).success
        StockReservations::SyncOperation.call(article: article_pos2.reload)
        stock_reservation
      end

      let!(:src_purchase_order) do
        create(:purchase_order,
               supplier:,
               status_category: :open,
               status: :ordered,
               purchase_order_entries: [
                 build(:purchase_order_entry, article: article_pos1, qty: 2, price: 10,
                                              originator: stock_reservation1),
                 build(:purchase_order_entry, article: article_pos2, qty: 2, price: 20,
                                              originator: stock_reservation2)
               ])
      end
      let!(:entry_quantities) do
        [
          { id: src_purchase_order.purchase_order_entries.first.id, qty: 1 },
          { id: src_purchase_order.purchase_order_entries.last.id, qty: 1 }
        ]
      end

      it 'returns successfull result' do
        expect { subject }.to change { PurchaseOrder.count }.by(1).and change { PurchaseOrderEntry.count }.by(2)

        expect(subject).to be_success
        expect(subject.success).to be_a(PurchaseOrder)
        expect(subject.success).to be_persisted
        expect(subject.success.linked_to_id).to eq(src_purchase_order.id)
        expect(subject.success.status_delivered?).to be_truthy
        expect(subject.success.purchase_order_entries.count).to eq(2)
        expect(subject.success.purchase_order_entries.first.qty).to eq(1)
        expect(subject.success.purchase_order_entries.first.price).to eq(10)
        expect(subject.success.purchase_order_entries.last.qty).to eq(1)
        expect(subject.success.purchase_order_entries.last.price).to eq(20)

        expect(src_purchase_order.reload.purchase_order_entries.first.qty).to eq(1)
        expect(src_purchase_order.purchase_order_entries.first.price).to eq(10)
        expect(src_purchase_order.purchase_order_entries.last.qty).to eq(1)
        expect(src_purchase_order.purchase_order_entries.last.price).to eq(20)
      end
    end

    context 'Split an order with 2 entries each with 0 qty ' do
      let!(:issue) { create(:issue, status_category: :in_progress, status: :ordered) }
      let!(:issue_entry1) do
        issue_entry1 = create(:issue_entry, issue:, article: article_pos1, qty: 2, price: 10)
        IssueEntries::CreateStockReservationOperation.call(issue_entry: issue_entry1)
        StockReservations::SyncOperation.call(article: article_pos1.reload)
        issue_entry1
      end

      let!(:stock_reservation1) do
        stock_reservation = IssueEntries::CreateStockReservationOperation.call(issue_entry: issue_entry1).success
        StockReservations::SyncOperation.call(article: article_pos1.reload)
        stock_reservation
      end

      let!(:issue_entry2) do
        create(:issue_entry, issue:, article: article_pos2, qty: 2, price: 20)
      end

      let!(:stock_reservation2) do
        stock_reservation = IssueEntries::CreateStockReservationOperation.call(issue_entry: issue_entry2).success
        StockReservations::SyncOperation.call(article: article_pos2.reload)
        stock_reservation
      end

      let!(:src_purchase_order) do
        create(:purchase_order,
               supplier:,
               status_category: :open,
               status: :ordered,
               purchase_order_entries: [
                 build(:purchase_order_entry, article: article_pos1, qty: 2, price: 10,
                                              originator: stock_reservation1),
                 build(:purchase_order_entry, article: article_pos2, qty: 2, price: 20,
                                              originator: stock_reservation2)
               ])
      end
      let!(:entry_quantities) do
        [
          { id: src_purchase_order.purchase_order_entries.first.id, qty: 0 },
          { id: src_purchase_order.purchase_order_entries.last.id, qty: 0 }
        ]
      end

      it 'returns successfull result' do
        expect { subject }.to change { PurchaseOrder.count }.by(0).and change { PurchaseOrderEntry.count }.by(0)
        expect(subject).to be_failure
      end

      context 'when  quantities are provided for split with zero value' do
        let!(:entry_quantities) do
          [
            { id: src_purchase_order.purchase_order_entries.first.id, qty: 1 }, # Change the quantity here
            { id: src_purchase_order.purchase_order_entries.last.id, qty: 0 }
          ]
        end

        it 'it creates a new purchase order' do
          expect { subject }.to change { PurchaseOrder.count }.by(1).and change { PurchaseOrderEntry.count }.by(1)
          expect(subject).to be_success
          # expect(subject.failure).to include("Die Menge der Bestellpositionen ist fehlerhaft.")
        end
      end

      context 'when invalid quantities are provided for split' do
        let!(:entry_quantities) do
          [
            { id: src_purchase_order.purchase_order_entries.first.id, qty: 2 }, # Change the quantity here
            { id: src_purchase_order.purchase_order_entries.last.id, qty: 2 }
          ]
        end

        it 'doesnt creates a new purchase order' do
          expect { subject }.to change { PurchaseOrder.count }.by(0).and change { PurchaseOrderEntry.count }.by(0)
          expect(subject).to be_failure
          expect(subject.failure).to include("Die Bestellung kann nicht aufgeteilt werden, " \
                                             "da Sie alle Positionen ausgewählt haben.")
        end
      end
    end

    context 'Split an order with 2 entries each with 1 qty less without immediate stock' do
      let(:stock_immediately) { false }
      let!(:issue) { create(:issue, status_category: :in_progress, status: :ordered) }
      let!(:issue_entry1) do
        issue_entry1 = create(:issue_entry, issue:, article: article_pos1, qty: 2, price: 10)
        IssueEntries::CreateStockReservationOperation.call(issue_entry: issue_entry1)
        StockReservations::SyncOperation.call(article: article_pos1.reload)
        issue_entry1
      end

      let!(:stock_reservation1) do
        stock_reservation = IssueEntries::CreateStockReservationOperation.call(issue_entry: issue_entry1).success
        StockReservations::SyncOperation.call(article: article_pos1.reload)
        stock_reservation
      end

      let!(:issue_entry2) do
        create(:issue_entry, issue:, article: article_pos2, qty: 2, price: 20)
      end

      let!(:stock_reservation2) do
        stock_reservation = IssueEntries::CreateStockReservationOperation.call(issue_entry: issue_entry2).success
        StockReservations::SyncOperation.call(article: article_pos2.reload)
        stock_reservation
      end

      let!(:src_purchase_order) do
        create(:purchase_order,
               supplier:,
               status_category: :open,
               status: :ordered,
               purchase_order_entries: [
                 build(:purchase_order_entry, article: article_pos1, qty: 2, price: 10,
                                              originator: stock_reservation1),
                 build(:purchase_order_entry, article: article_pos2, qty: 2, price: 20,
                                              originator: stock_reservation2)
               ])
      end
      let!(:entry_quantities) do
        [
          { id: src_purchase_order.purchase_order_entries.first.id, qty: 1 },
          { id: src_purchase_order.purchase_order_entries.last.id, qty: 1 }
        ]
      end

      it 'returns successfull result' do
        expect { subject }.to change { PurchaseOrder.count }.by(1).and change { PurchaseOrderEntry.count }.by(2)

        expect(subject).to be_success
        expect(subject.success).to be_a(PurchaseOrder)
        expect(subject.success.status_ordered?).to be_truthy
        expect(subject.success).to be_persisted
        expect(subject.success.purchase_order_entries.count).to eq(2)
        expect(subject.success.purchase_order_entries.first.qty).to eq(1)
        expect(subject.success.purchase_order_entries.first.price).to eq(10)
        expect(subject.success.purchase_order_entries.last.qty).to eq(1)
        expect(subject.success.purchase_order_entries.last.price).to eq(20)
        expect(subject.success.linked_to_id).to eq(src_purchase_order.id)

        expect(src_purchase_order.reload.purchase_order_entries.first.qty).to eq(1)
        expect(src_purchase_order.purchase_order_entries.first.price).to eq(10)
        expect(src_purchase_order.purchase_order_entries.last.qty).to eq(1)
        expect(src_purchase_order.purchase_order_entries.last.price).to eq(20)
      end
    end
  end
end
