RSpec.describe Articles::BeautifyPriceOperation do
  describe "#call" do
    subject(:call) do
      described_class.call(article:)
    end

    include_context "setup demo account and user"
    include_context "setup system user"

    context 'when data valid ' do
      let(:article) { create(:article) }

      it 'returns successfull result' do
        expect(subject).to be_success
        expect(subject.success).to be_a(Article)
        # expect(subject.success).to be_persisted
        # expect(subject.success).to have_attributes({ key: value })
      end
    end
  end
end
