RSpec.describe Sms::RecloudProvider do
  describe "#call" do
    subject(:call) do
      described_class.call(text:, to:)
    end

    let(:to) { "+49123456789" }
    let(:text) { "Hello World" }

    include_context "setup demo account and user"
    include_context "setup system user"

    describe "when data are not valid" do
      context "when country code is not german" do
        let(:to) { "+123456789" }
        it {
          expect(subject).to be_failure
          expect(subject.failure).to eq("International code not supported")
        }
      end
      context "when number is too short" do
        let(:to) { "0123456" }
        it {
          expect(subject).to be_failure
          expect(subject.failure).to eq("Invalid phone number")
        }
      end
      context "when number is too long" do
        let(:to) { "0123456123123123123123" }
        it {
          expect(subject).to be_failure
          expect(subject.failure).to eq("Invalid phone number")
        }
      end
      context "when text length is too long" do
        let(:text) { "A" * 160 * 4 }
        it {
          expect(subject).to be_failure
          expect(subject.failure).to eq("Message is too long")
        }
      end

      context "when text length is too long" do
        let(:text) { "    " }
        it {
          expect(subject).to be_failure
          expect(subject.failure).to eq("Message is empty")
        }
      end
    end
  end
end
