RSpec.describe RecentSearchItems::ReadOperation do
  describe "#call" do
    subject(:call) do
      described_class.call(class_name:)
    end
    include_context "setup demo account and user"
    include_context "setup system user"

    let(:class_name) { "Customer" }
    let(:cached_data) { Array.new(5) { |i| { id: i, class_name: }.to_json } }

    before do
      allow(Rails.cache).to receive(:fetch).with(
        "customer_recent_searches_#{Current.user.id}"
      ).and_return(cached_data)
    end

    it "returns an array of model hashes" do
      result = call
      expect(result).to be_an(Array)
      expect(result.first).to have_key('id')
      expect(result.first).to have_key('class_name')
      expect(result.size).to eq(5)
    end

    context "when the cache is empty" do
      let(:cached_data) { [] }

      it "returns an empty array" do
        result = call
        expect(result).to be_empty
      end
    end
  end
end
