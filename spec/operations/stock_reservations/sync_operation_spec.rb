RSpec.describe StockReservations::SyncOperation do
  include_context "setup system user"
  include_context "setup demo account and user"

  let(:issue) { create(:issue) }
  let(:article) { create(:article) }

  let(:stock_location) { create(:stock_location) }
  let(:stock_area) { create(:stock_area, stock_location:) }

  let!(:stock_movement) do
    sm = create(:stock_movement, article:, stock_location:, stock_area:, qty: in_stock_available)
    Stocks::StockMovements::CreatedEvent::StockInOut.call(stock_movement_id: sm.id)
  end

  describe "#call" do
    subject(:call) do
      described_class.call(article:)
    end

    # Testing the scenario where the available stock quantity matches the reservation quantity.
    context "When the available stock quantity matches the reservation quantity" do
      let(:in_stock_available) { 2 }
      let(:reservation_qty) { 2 }
      let!(:stock_reservation) do
        create(:stock_reservation, qty: reservation_qty, article: article.reload, originator: issue)
      end
      it "it return Success and reserve a stock" do
        expect(call).to be_success
        expect(stock_reservation.reload.reserved_at).to be_present
        expect(article.stock.reload.reserved).to eq(2)
      end
    end

    # Testing the scenario where the available stock quantity is less than the reservation quantity.
    context "When the available stock is insufficient for the reservation" do
      let(:in_stock_available) { 1 }
      let(:reservation_qty) { 2 }
      let!(:stock_reservation) do
        create(:stock_reservation, qty: reservation_qty, article: article.reload, originator: issue)
      end
      it "it return Success and reserve a stock " do
        expect(call).to be_success
        expect(stock_reservation.reload.reserved_at).to be_nil
        expect(article.stock.reload.reserved).to eq(2)
      end
    end

    # Testing the scenario where there are multiple reservations with the same quantity as the available stock.
    context "When multiple reservations exist with total quantity equal to available stock" do
      let(:in_stock_available) { 2 }
      let(:reservation_qty) { 2 }

      let!(:stock_reservation1) do
        create(:stock_reservation, qty: 1, article: article.reload, originator: issue)
      end
      let!(:stock_reservation) do
        create(:stock_reservation, qty: 1, article: article.reload, originator: issue)
      end
      it "it return Success and reserve a stock " do
        expect(call).to be_success
        expect(stock_reservation1.reload.reserved_at).to be_present
        expect(stock_reservation.reload.reserved_at).to be_present
        expect(article.stock.reload.reserved).to eq(2)
      end
    end

    # Testing the scenario where multiple reservations have different priorities and the available stock can only fulfill the higher priority reservation.
    context "When stock is limited and only the higher priority reservation can be fulfilled" do
      let(:in_stock_available) { 1 }

      let!(:stock_reservation1) do
        create(:stock_reservation, qty: 1, article: article.reload, originator: issue, prio: 100)
      end
      let!(:stock_reservation) do
        create(:stock_reservation, qty: 1, article: article.reload, originator: issue, prio: 0)
      end
      it "it return Success and reserve only 1 item stock " do
        expect(call).to be_success
        expect(stock_reservation1.reload.reserved_at).to be_present
        expect(stock_reservation.reload.reserved_at).to be_nil
        expect(article.stock.reload.reserved).to eq(2)
      end
    end

    # Testing the scenario where multiple reservations have different fulfillment deadlines and priorities.
    context "When reservations have different fulfillment deadlines and priorities" do
      let(:in_stock_available) { 2 }

      let!(:stock_reservation2) do
        create(:stock_reservation, qty: 1, article: article.reload, originator: issue, prio: 0,
                                   fulfill_before: 5.days.from_now)
      end

      let!(:stock_reservation1) do
        create(:stock_reservation, qty: 1, article: article.reload, originator: issue, prio: 100,
                                   fulfill_before: 10.days.from_now)
      end
      let!(:stock_reservation) do
        create(:stock_reservation, qty: 1, article: article.reload, originator: issue, prio: 0)
      end
      it "it return Success and reserve a stock " do
        expect(call).to be_success
        expect(stock_reservation1.reload.reserved_at).to be_present
        expect(stock_reservation2.reload.reserved_at).to be_present
        expect(stock_reservation.reload.reserved_at).to be_nil
        expect(article.stock.reload.reserved).to eq(3)
      end
    end

    # Testing the scenario where there's limited stock, and multiple reservations have different priorities and fulfillment deadlines.
    context "When stock is limited and reservations have varying priorities and deadlines" do
      let(:in_stock_available) { 1 }

      let!(:stock_reservation1) do
        create(:stock_reservation, qty: 1, article: article.reload, originator: issue, prio: 100,
                                   fulfill_before: 5.days.from_now)
      end

      let!(:stock_reservation2) do
        create(:stock_reservation, qty: 1, article: article.reload, originator: issue, prio: 100,
                                   fulfill_before: 10.days.from_now)
      end
      let!(:stock_reservation) do
        create(:stock_reservation, qty: 1, article: article.reload, originator: issue, prio: 0,
                                   reserved_at: 1.day.ago)
      end
      it "it return Success and reserve a stock reset existing reservation" do
        expect(call).to be_success
        expect(stock_reservation1.reload.reserved_at).to be_present
        expect(stock_reservation2.reload.reserved_at).to be_nil
        expect(stock_reservation.reload.reserved_at).to be_nil
        expect(article.stock.reload.reserved).to eq(3)
      end
    end
  end
end
