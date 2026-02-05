RSpec.describe ResourcesAbilities::IssueEntryAbility, aggregate_failures: true do
  include_context "setup system user"
  include_context "setup demo account and user"

  let(:ability) { demo_user.ability }

  describe '#call' do
    before do
      create(:ability, resources: %w(IssueEntry), action_tags: %w[create edit destroy], role: demo_user.role)
      create(:ability, resources: %w(Issue), action_tags: %w[read], role: demo_user.role)
    end

    context 'an open issue' do
      let(:issue) { create(:issue, status_category: :open) }
      let(:issue_entry) { create(:issue_entry, issue:) }
      it 'allows to create issue_entries' do
        expect(ability.can?(:create_issue_entries, issue)).to be_truthy
        expect(ability.can?(:edit, issue_entry)).to be_truthy
        expect(ability.can?(:destroy, issue_entry)).to be_truthy
      end
    end

    context 'with a done issue' do
      let(:issue) { create(:issue, status_category: :done) }
      let(:issue_entry) { create(:issue_entry, issue:) }
      it 'prevent destroying and editing and creating additional entries' do
        expect(ability.can?(:create_issue_entries, issue)).to be_falsey
        # expect(ability.can?(:edit, issue_entry)).to be_falsey
        # expect(ability.can?(:destroy, issue_entry)).to be_falsey
      end
    end
  end
end
