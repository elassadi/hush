RSpec.describe Articles::MarkAsInventoriedOperation do
  describe "#call" do
    subject(:call) do
      described_class.call(article:)
    end

    include_context "setup demo account and user"
    include_context "setup system user"

    let(:previous_inventoried_at) { 1.day.ago }
    let(:previous_inventoried_by_id) { 1 }

    before do
      # Set previous values for testing history
      article.update!(
        inventoried_at: previous_inventoried_at,
        inventoried_by_id: previous_inventoried_by_id
      )
    end

    context 'when data is valid' do
      let(:article) { create(:article) }

      it 'returns a successful result' do
        expect(subject).to be_success
        expect(subject.success).to be_a(Article)
        expect(subject.success).to be_persisted
      end

      it 'sets inventoried_at and inventoried_by_id' do
        expect { subject }.to change { article.reload.inventoried_at }.and(change { article.inventoried_by_id })

        expect(article.inventoried_at).to be_within(1.second).of(Time.current)
        expect(article.inventoried_by_id).to eq(demo_user.id)
      end

      it 'adds previous values to inventoried_history' do
        expect(subject).to be_success

        last_inventoried_history = article.inventoried_history.last
        expect(
          DateTime.parse(last_inventoried_history['inventoried_at']).to_date
        ).to eq(previous_inventoried_at.to_date)
        expect(last_inventoried_history['inventoried_by_id']).to eq(previous_inventoried_by_id)
      end
    end
  end
end
