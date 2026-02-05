RSpec.describe PurchaseOrders::ShouldDestroyOperation do
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

    let!(:supplier_source) { create(:supplier_source, article:) }

    context 'when a purchase order exists with only one entry ' do
      let!(:purchase_order) do
        create(
          :purchase_order,
          supplier: article.supplier,
          account: stock_reservation.account,
          purchase_order_entries: [
            build(
              :purchase_order_entry, article:, qty: 1, price: 10, originator: stock_reservation,
                                     account: stock_reservation.account
            )
          ]
        )
      end
      it 'returns successfull result and destroy the  purchase order' do
        expect(subject).to be_success
        expect { purchase_order.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when a purchase order exists an  entry with more than the stockreservation qty' do
      let!(:purchase_order) do
        create(
          :purchase_order,
          supplier: article.supplier,
          account: stock_reservation.account,
          purchase_order_entries: [
            build(
              :purchase_order_entry, article:, qty: stock_reservation.qty + 2, price: 10, originator: stock_reservation,
                                     account: stock_reservation.account
            )
          ]
        )
      end
      it 'returns successfull result and wont destroy the  purchase order' do
        expect(subject).to be_success
        expect(purchase_order.reload).to be_persisted
        expect(purchase_order.purchase_order_entries.count).to eq(1)
        expect(purchase_order.purchase_order_entries.first.qty).to eq(2)
      end
    end

    context 'when a purchase order exists but no no entry match ' do
      let!(:purchase_order) do
        create(
          :purchase_order,
          supplier: article.supplier,
          account: stock_reservation.account,
          purchase_order_entries: [
            build(
              :purchase_order_entry, article:, qty: stock_reservation.qty + 2, price: 10,
                                     account: stock_reservation.account
            )
          ]
        )
      end
      it 'returns successfull result and destroy the  purchase order' do
        expect(subject).to be_success
        expect(purchase_order.reload).to be_persisted
        expect(purchase_order.purchase_order_entries.first.qty).to eq(stock_reservation.qty + 2)
      end
    end

    context 'when a purchase order exists but issue is not open ' do
      let!(:purchase_order) do
        create(
          :purchase_order,
          supplier: article.supplier,
          account: stock_reservation.account,
          status_category: :in_progress,
          purchase_order_entries: [
            build(
              :purchase_order_entry, article:, qty: stock_reservation.qty + 2, price: 10, originator: stock_reservation,
                                     account: stock_reservation.account
            )
          ]
        )
      end
      it 'returns successfull result and destroy the  purchase order' do
        expect(subject).to be_success
        expect(purchase_order.reload).to be_persisted
        expect(purchase_order.purchase_order_entries.first.qty).to eq(stock_reservation.qty + 2)
      end
    end

    context 'when a purchase order exists with an entry matching the stock reservation qty' do
      let!(:purchase_order) do
        create(
          :purchase_order,
          supplier: article.supplier,
          account: stock_reservation.account,
          status_category: :in_progress,
          purchase_order_entries: [
            build(
              :purchase_order_entry, article:, qty: stock_reservation.qty, price: 10,
                                     originator: stock_reservation,
                                     account: stock_reservation.account
            )
          ]
        )
      end
      it 'returns successful result and detach the stock reservation from the purchase order entry' do
        expect(subject).to be_success
        expect(purchase_order.reload).to be_persisted
        expect(purchase_order.purchase_order_entries.first.stock_reservation).to be_nil
      end
    end
    context 'when no purchase order exists ' do
      it 'returns successfull result ' do
        expect(subject).to be_success
      end
    end
  end
end
