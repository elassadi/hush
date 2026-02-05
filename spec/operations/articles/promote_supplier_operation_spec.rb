RSpec.describe Articles::PromoteSupplierOperation do
  describe "#call" do
    subject(:call) do
      described_class.call(article:)
    end

    include_context "setup demo account and user"
    include_context "setup system user"

    let(:article) { create(:article) }
    let(:supplier) { create(:supplier) }
    let!(:supplier2) { create(:supplier) }
    let!(:supplier3) { create(:supplier) }
    context 'when purchase_price is lower ' do
      let!(:supplier_source_1) do
        create(
          :supplier_source, article:, supplier:, stock_status: 'available',
                            favorite: false, days_to_ship: 1, purchase_price: 5
        )
      end
      let!(:supplier_source_2) do
        create(
          :supplier_source, article:, supplier: supplier2, stock_status: 'available',
                            favorite: false, days_to_ship: 1, purchase_price: 4
        )
      end

      it 'returns successfull result' do
        # expect { subject }.to change { Article.count }.by(1)
        expect(subject).to be_success
        expect(subject.success).to be_a(Article)
        expect(subject.success).to be_persisted
        expect(subject.success.supplier).to eq(supplier2)
        # expect(subject.success).to have_attributes({ key: value })
      end
    end

    context 'when supplier is favorite ' do
      let!(:supplier_source_1) do
        create(
          :supplier_source, article:, supplier:, stock_status: 'available',
                            favorite: true, days_to_ship: 1, purchase_price: 5
        )
      end
      let!(:supplier_source_2) do
        create(
          :supplier_source, article:, supplier: supplier2, stock_status: 'available',
                            favorite: false, days_to_ship: 1, purchase_price: 4
        )
      end

      it 'returns successfull result' do
        # expect { subject }.to change { Article.count }.by(1)
        expect(subject).to be_success
        expect(subject.success).to be_a(Article)
        expect(subject.success).to be_persisted
        expect(subject.success.supplier).to eq(supplier)
        # expect(subject.success).to have_attributes({ key: value })
      end
    end

    context 'when supplier is favorite but stock is unavailable ' do
      let!(:supplier_source_1) do
        create(
          :supplier_source, article:, supplier:, stock_status: 'unavailable',
                            favorite: true, days_to_ship: 1, purchase_price: 5
        )
      end
      let!(:supplier_source_2) do
        create(
          :supplier_source, article:, supplier: supplier2, stock_status: 'available',
                            favorite: false, days_to_ship: 1, purchase_price: 4
        )
      end

      it 'returns successfull result' do
        # expect { subject }.to change { Article.count }.by(1)
        expect(subject).to be_success
        expect(subject.success).to be_a(Article)
        expect(subject.success).to be_persisted
        expect(subject.success.supplier).to eq(supplier2)
        # expect(subject.success).to have_attributes({ key: value })
      end
    end

    context 'when supplier is favorite but stock is unavailable and days_to_ship are not the same ' do
      let!(:supplier_source_1) do
        create(
          :supplier_source, article:, supplier:, stock_status: 'unavailable',
                            favorite: true, days_to_ship: 1, purchase_price: 5
        )
      end
      let!(:supplier_source_2) do
        create(
          :supplier_source, article:, supplier: supplier2, stock_status: 'available',
                            favorite: false, days_to_ship: 3, purchase_price: 4
        )
      end
      let!(:supplier_source_3) do
        create(
          :supplier_source, article:, supplier: supplier3, stock_status: 'available',
                            favorite: false, days_to_ship: 1, purchase_price: 4
        )
      end

      it 'returns successfull result' do
        # expect { subject }.to change { Article.count }.by(1)
        expect(subject).to be_success
        expect(subject.success).to be_a(Article)
        expect(subject.success).to be_persisted
        expect(subject.success.supplier).to eq(supplier3)
        # expect(subject.success).to have_attributes({ key: value })
      end
    end
  end
end
