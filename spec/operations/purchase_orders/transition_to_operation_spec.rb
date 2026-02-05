RSpec.describe PurchaseOrders::TransitionToOperation do
  include_context "setup system user"
  include_context "setup demo account and user"

  let(:purchase_order) { create(:purchase_order, status: :draft) }

  let(:comment) { "somecomment" }

  let(:role) { create :role, name: :demo }
  let!(:ability) do
    create(:ability, resources: %w(PurchaseOrder), action_tags: %w[read create update cancel order_delivered], role:)
  end

  describe "#call" do
    subject(:call) do
      described_class.call(purchase_order:, event:, comment:, owner: demo_user)
    end

    before do
      demo_user.update(role:)
    end

    context "With non runable event" do
      let(:event) { "not_existing_event" }
      it "it return failure " do
        result = call
        expect(result).to be_failure
      end
    end

    context "With runable event" do
      let(:event) { "cancel" }
      it "it run the event and change the workflow to the new state " do
        expect do
          result = call
          expect(result).to be_success
        end.to change(purchase_order, :status).from("draft").to("canceld")
                                              .and change(Comment, :count).by(1)
      end
    end

    context "With runable event" do
      let(:event) { "order_delivered" }
      let(:purchase_order) { create(:purchase_order, status: "ordered", status_category: :in_progress) }
      it "it run the event and change the workflow to delivered " do
        expect do
          result = call
          expect(result).to be_success
        end.to change(purchase_order, :status).from("ordered").to("delivered")
                                              .and change(Comment, :count).by(1)
      end
    end
  end
end
