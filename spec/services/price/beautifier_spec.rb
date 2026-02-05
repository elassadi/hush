RSpec.describe Prices::Beautifier do
  describe "#call" do
    subject(:call) do
      described_class.call(original_price: price)
    end

    include_context "setup demo account and user"
    include_context "setup system user"

    describe "should round the price according to second step bis max 10 " do
      let(:price) { 1.11 }
      it { expect(subject.success).to eq(1.49) }
    end

    describe "should round the price according to second step bis max 10 " do
      let(:price) { 3.380 }
      it { expect(subject.success).to eq(3.49) }
    end

    describe "should round the price according to second step bis max 30 " do
      let(:price) { 12.05 }
      it { expect(subject.success).to eq(12.99) }
    end

    describe "should round the price according to second step bis max 30 " do
      let(:price) { 27.17 }
      it { expect(subject.success).to eq(27.99) }
    end

    describe "should round the price according to second step bis max 30 " do
      let(:price) { 47.22 }
      it { expect(subject.success).to eq(49.99) }
    end

    describe "should round the price according to second step bis max 30 " do
      let(:price) { 55.05 }
      it { expect(subject.success).to eq(54.99) }
    end

    describe "should round the price according to second step bis max 100 " do
      let(:price) { 89.05 }
      it { expect(subject.success).to eq(89.99) }
    end

    describe "should round the price according to second step bis max 100 " do
      let(:price) { 80.45 }
      it { expect(subject.success).to eq(79.99) }
    end

    describe "should round the price according to second step bis max 100 " do
      let(:price) { 160.1 }
      it { expect(subject.success).to eq(159.99) }
    end

    describe "should round the price according to second step bis max 100 " do
      let(:price) { 550.054 }
      it { expect(subject.success).to eq(549.99) }
    end

    describe "should round the price according to second step bis max 100 " do
      let(:price) { 449.054 }
      it { expect(subject.success).to eq(449.99) }
    end

    describe "should round the price according to second step bis max 100 " do
      let(:price) { 717.054 }
      it { expect(subject.success).to eq(719.99) }
    end
  end
end
