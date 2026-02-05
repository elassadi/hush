RSpec.describe RecloudCore::Authorization::AuthorizeActionForAssociation, aggregate_failures: true do
  include_context "setup system user"
  include_context "setup demo account and user"

  subject(:call) do
    described_class.call(action:, subject: customer, user: demo_user, debug: true)
  end

  let(:customer) { create :customer }
  let(:address) { create :address, status: :active, addressable: customer }
  let(:role) { create :role, name: :demo }
  let!(:ability) do
    create(:ability, resources: %w(Address), action_tags: %w[read create update], role:)
  end

  describe '#call' do
    before do
      demo_user.update(role:)
    end

    context 'with valid permission' do
      let(:action) { :create_addresses }
      it 'return granted response' do
        expect(call).to be_success
        expect(call.success).to include(authorisation: :granted, cannot_rule_exists: false)
      end
    end

    context 'with no valid permission' do
      let(:action) { :import_addresses }
      it 'return granted response' do
        expect(call).to be_success
        expect(call.success).to include(authorisation: :denied, cannot_rule_exists: false)
      end
    end

    context 'with valid permission but a cannot definition' do
      before do
        demo_user.ability.cannot(:create_addresses, Customer)
      end

      let(:action) { :create_addresses }
      it 'return granted response' do
        expect(call).to be_success
        expect(call.success).to include(authorisation: :denied, cannot_rule_exists: true)
      end
    end
  end
end
