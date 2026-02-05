RSpec.describe RecentSearchItems::SaveOperation do
  describe "#call" do
    subject(:call) do
      described_class.call(model: model_instance)
    end

    include_context "setup demo account and user"
    include_context "setup system user"

    let(:model_instance) { create(:customer, id: 1) }

    before do
      allow(Rails.cache).to receive(:write)
      allow(Rails.cache).to receive(:fetch).and_return([])
    end

    it "saves the model information in the cache" do
      call
      expect(Rails.cache).to have_received(:write).with(
        "#{model_instance.class.name.downcase}_recent_searches_#{Current.user.id}",
        ['{"id":1,"class_name":"Customer"}']
      )
    end

    context "when the cache has maximum items" do
      let(:cached_data) { Array.new(10) { |i| { id: i, class_name: model_instance.class.name }.to_json } }

      before do
        allow(Rails.cache).to receive(:fetch).and_return(cached_data)
      end

      it "removes the oldest item from the cache" do
        call
        expect(Rails.cache).to have_received(:write) do |_key, value|
          expect(value.size).to eq(5) # Ensure we still have 5 items
          expect(value.last).not_to include(cached_data.first) # Oldest item is removed
        end
      end
    end

    context 'when the item is already in the cache' do
      let(:cached_data) do
        [
          { id: 2, class_name: 'Customer' }.to_json,
          { id: 1, class_name: 'Customer' }.to_json, # This is the duplicate we want to move to the front
          { id: 3, class_name: 'Customer' }.to_json
        ]
      end
      before do
        allow(Rails.cache).to receive(:fetch).and_return(cached_data)
      end

      it 'reorders the item to the top of the list without duplicating' do
        call
        expect(Rails.cache).to have_received(:write) do |_key, value|
          expect(value.first).to eq({ id: 1, class_name: 'Customer' }.to_json)
          expect(value).to include({ id: 2, class_name: 'Customer' }.to_json)
          expect(value).to include({ id: 3, class_name: 'Customer' }.to_json)
          expect(value.size).to eq(3)
        end
      end

      context 'when the item is not in the cache' do
        let(:model_instance) { create(:customer, id: 4) }
        it 'adds the new item to the top of the list and maintains list size' do
          call
          expect(Rails.cache).to have_received(:write) do |_key, value|
            expect(value.first).to eq({ id: 4, class_name: 'Customer' }.to_json)
            expect(value.size).to eq(4) # Assuming we're not hitting the MAX_ITEMS limit here
          end
        end
      end
    end
  end
end
