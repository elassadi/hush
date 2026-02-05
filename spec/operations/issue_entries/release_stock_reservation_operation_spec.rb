RSpec.describe IssueEntries::ReleaseStockReservationOperation do
  describe "#call" do
    subject(:call) do
      described_class.call(issue_entry: issue_entry.reload)
    end

    include_context "setup demo account and user"

    let(:issue) { create(:issue) }
    let(:article_type) { "basic" }
    let(:article) { create(:article, article_type:) }
    let(:issue_entry) { create(:issue_entry, issue:, article:, qty: 1, price: 10) }

    context 'When an article is stockable' do
      let(:stock_location) { create(:stock_location) }
      let(:stock_area) { create(:stock_area, account: recloud_account, stock_location:) }
      let!(:stock_item) { create(:stock_item, article:, account: recloud_account, stock_area:) }

      let!(:stock_movement) do
        sm = create(
          :stock_movement, article:, owner: Current.user, stock_area:, qty: 1,
                           stock_location:, action: :stock_in, action_type: :stock_with_referenz, originator: issue_entry
        )
        # article.stock.add_to_stock_quantity(1)
        # stock_item.add_to_stock_quantity(1)
        ::Stocks::StockMovements::CreatedEvent::StockInOut.call(stock_movement_id: sm.id)
        sm
      end
      let!(:stock_reservation) do
        create(:stock_reservation,
               article:, originator: issue_entry, qty: 1, status: :reserved, fulfilled_at: nil)
      end

      it 'creates a stockmovment stock_out' do
        allow(Event).to receive(:broadcast)
        expect { subject }.to change { StockMovement.count }.by(1)
        expect(subject).to be_success
        expect(StockMovement.last.action).to eq('stock_out')
        expect(StockMovement.last.action_type).to eq('stock_with_referenz')
        expect(StockMovement.last.originator).to eq(issue_entry)
        expect(Event).to have_received(:broadcast).with(:stock_movement_created, an_instance_of(Hash))
      end
    end

    context 'When an article is not stockable' do
      let(:article_type) { "service" }
      it "returns a failure" do
        expect { subject }.to change { StockMovement.count }.by(0)
        expect(subject).to be_failure
      end
    end
  end
end
