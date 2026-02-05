RSpec.describe Articles::MarkAsInventoriedTransaction do
  describe "#call" do
    subject(:call) do
      described_class.call(article_id: article.id)
    end

    include_context "setup demo account and user"
    include_context "setup system user"

    let(:operation) do
      instance_double(Articles::MarkAsInventoriedOperation)
    end

    before do
      allow(Articles::MarkAsInventoriedOperation).to receive(:new)
        .with({ article: })
        .and_return(operation)
    end

    context "with valid data " do
      let(:article) { create(:article) }

      it "returns success result" do
        expect(operation).to receive(:call).and_return(Dry::Monads::Success(article))
        expect(call).to be_success
        expect(call.success).to eq(article)
      end
    end
  end
end
