RSpec.describe RecloudCore::Authorization::AuthorizeAction, aggregate_failures: true do
  include_context "setup system user"
  include_context "setup demo account and user"

  subject(:call) do
    described_class.call(action:, subject:, user: demo_user, debug: true)
  end

  let(:customer) { create :customer }
  let(:subject) { create :address, status: :active, addressable: customer }
  let(:role) { create :role, name: :demo }
  let!(:ability) do
    create(:ability, resources: %w(Address), action_tags: %w[read create update], role:)
    create(:ability, resources: %w(IssueEntry), action_tags: %w[read create update destroy], role:)
  end

  describe '#call' do
    before do
      demo_user.update(role:)
    end

    context 'with valid permission' do
      let(:action) { :create }
      it 'return granted response' do
        expect(call).to be_success
        expect(call.success).to include(authorisation: :granted, cannot_rule_exists: false)
      end
    end

    context 'with no valid permission' do
      let(:action) { :destroy }
      it 'return granted response' do
        expect(call).to be_success
        expect(call.success).to include(authorisation: :denied, cannot_rule_exists: false)
      end
    end

    context 'with no valid permission and cannot definition' do
      before do
        demo_user.ability.cannot(:import_data, Address)
      end

      let(:action) { :import_data }
      it 'return granted response' do
        expect(call).to be_success
        expect(call.success).to include(authorisation: :denied, cannot_rule_exists: true)
      end
    end

    context 'with no valid permission and cannot definition' do
      let(:action) { :destroy }
      let(:issue) { create(:issue, status_category: :done) }
      let(:subject) { create :issue_entry, issue: }
      it 'return granted response' do
        expect(call).to be_success
        expect(call.success).to include(authorisation: :denied, cannot_rule_exists: true)
      end
    end
  end
end
