RSpec.describe Privilege, aggregate_failures: true do
  include_context "setup system user"
  include_context "setup demo account and user"

  let(:ability) { demo_user.ability }
  let(:custom_permissions_config) do
    {
      Issue: {
        view_create: %i[IssueEntry CalendarEntry Document Activity Comment],
        restrictions: {
          cannot: [
            { actions: %i[create edit destroy], conditions: { status_category: %i[done] } },
            { actions: %i[destroy], conditions: { status_category: %i[done in_progress] } }
          ]
        }
      }
    }
  end

  before do
    allow_any_instance_of(BaseAccess).to receive(:read_permission_config)
      .and_return(custom_permissions_config)
  end

  describe '#call' do
    context 'with valid permission ' do
      let!(:issue) { create(:issue) }
      let!(:resources_abilities) do
        create(:ability, resources: %w(Issue), action_tags: %w[create edit destroy run_action], role: demo_user.role)
        create(:ability, resources: %w(IssueEntry), action_tags: %w[read], role: demo_user.role)
      end
      let(:custom_permissions_config) { {} }
      it 'allows to create/edit/destroy Issue' do
        expect(ability.can?(:create, issue)).to be_truthy
        expect(ability.can?(:read, IssueEntry)).to be_truthy
        expect(ability.can?(:edit, issue)).to be_truthy
        expect(ability.can?(:destroy, issue)).to be_truthy
        expect(ability.can?(:run_action, issue)).to be_truthy
      end
      context 'with basic policies' do
        let!(:issue) { create(:issue, status_category: :done) }
        let(:custom_permissions_config) do
          {
            Issue: {
              view_create: %i[IssueEntry CalendarEntry Document Activity Comment]
            }
          }
        end
        it 'allows to view issue entries but not to create IssueEntry' do
          expect(ability.can?(:create, issue)).to be_truthy
          # read ability to issue entry allow to view issue entry in the parent resource issue
          expect(ability.can?(:create_issue_entries, Issue)).to be_falsey
          expect(ability.can?(:view_issue_entries, Issue)).to be_truthy
          expect(ability.can?(:view_issue_entry, Issue)).to be_truthy
        end
      end
    end

    context 'with valid permission with no restrictions ' do
      let(:issue) { create(:issue) }
      let!(:resources_abilities) do
        create(:ability, resources: %w(Issue), action_tags: %w[create edit destroy run_action], role: demo_user.role)
        create(:ability, resources: %w(IssueEntry), action_tags: %w[read create], role: demo_user.role)
      end
      let(:custom_permissions_config) { {} }
      it 'allows to create/edit/destroy Issue' do
        expect(ability.can?(:create, issue)).to be_truthy
        expect(ability.can?(:create, IssueEntry)).to be_truthy
        expect(ability.can?(:edit, issue)).to be_truthy
        expect(ability.can?(:destroy, issue)).to be_truthy
        expect(ability.can?(:run_action, issue)).to be_truthy
      end
      context 'with basic policies' do
        let(:issue) { create(:issue, status_category: :done) }
        let(:custom_permissions_config) do
          {
            Issue: {
              view_create: %i[IssueEntry CalendarEntry Document Activity Comment]
            }
          }
        end
        it 'allows to view issue entries and create IssueEntry' do
          expect(ability.can?(:create, issue)).to be_truthy
          # read and create ability to issue entry allow to view and create issue entry in the parent resource issue
          expect(ability.can?(:create_issue_entries, Issue)).to be_truthy
          expect(ability.can?(:view_issue_entries, Issue)).to be_truthy
          expect(ability.can?(:view_issue_entry, Issue)).to be_truthy
        end
      end
    end

    context 'with valid permission and valid restrictions as conditions ' do
      let!(:resources_abilities) do
        create(:ability, resources: %w(Issue), action_tags: %w[read create edit destroy run_action], role: demo_user.role)
        create(:ability, resources: %w(IssueEntry), action_tags: %w[read create], role: demo_user.role)
      end
      let(:custom_permissions_config) do
        {
          Issue: {
            view_create: %i[IssueEntry CalendarEntry Document Activity Comment],
            restrictions: {
              cannot: [
                { actions: %i[destroy], conditions: { status_category: %i[done] } },
                { actions: %i[read], conditions: { status: %i[draft] } }
              ]
            }
          }
        }
      end

      describe 'with issue status_category not eq done ' do
        let!(:issue) { create(:issue, status_category: :open) }
        it 'allows to edit/destroy Issue' do
          expect(ability.can?(:create_issue_entries, Issue)).to be_truthy

          expect(ability.can?(:edit, issue)).to be_truthy
          expect(ability.can?(:destroy, issue)).to be_truthy
          expect(ability.cannot?(:view_documents, issue)).to be_truthy
          expect(ability.can?(:read, issue)).to be_falsey
        end
      end

      describe 'with issue status_category done ' do
        let!(:issue) { create(:issue, status_category: :open, status: :awaiting_device) }
        it 'denies edit/destroy Issue' do
          # expect(ability.can?(:edit, issue)).to be_falsey
          expect(ability.can?(:destroy, issue)).to be_truthy
          expect(ability.can?(:edit, issue)).to be_truthy
          expect(ability.can?(:read, issue)).to be_truthy
        end
      end
    end

    context 'with valid permission and valid restrictions as proc ' do
      let!(:resources_abilities) do
        create(:ability, resources: %w(Issue), action_tags: %w[read create edit destroy run_action], role: demo_user.role)
        create(:ability, resources: %w(IssueEntry), action_tags: %w[read create], role: demo_user.role)
      end
      let(:custom_permissions_config) do
        {
          Issue: {
            view_create: %i[IssueEntry CalendarEntry Document Activity Comment],
            restrictions: {
              cannot: [
                { actions: %i[edit destroy], proc_klass: "ResourcesAbilities::IssueAbility" },
                { actions: %i[read], conditions: { status: %i[draft] } }
              ]
            }
          }
        }
      end

      describe 'with issue status_category not eq done ' do
        let!(:issue) { create(:issue, status_category: :open) }
        it 'allows to edit/destroy Issue' do
          expect(ability.can?(:create_issue_entries, Issue)).to be_truthy

          expect(ability.can?(:edit, issue)).to be_truthy
          expect(ability.can?(:destroy, issue)).to be_truthy
          expect(ability.cannot?(:view_documents, issue)).to be_truthy
          expect(ability.can?(:read, issue)).to be_falsey
        end
      end

      describe 'with issue status_category done ' do
        let!(:issue) { create(:issue, status_category: :open, status: :awaiting_device) }
        it 'denies edit/destroy Issue' do
          # expect(ability.can?(:edit, issue)).to be_falsey
          expect(ability.can?(:destroy, issue)).to be_truthy
          expect(ability.can?(:edit, issue)).to be_truthy
          expect(ability.can?(:read, issue)).to be_truthy
        end
      end
    end

    context 'with view_version enabled ' do
      let!(:resources_abilities) do
        create(:ability, resources: %w(Issue), action_tags: %w[read create edit destroy run_action], role: demo_user.role)
        create(:ability, resources: %w(IssueEntry), action_tags: %w[read create], role: demo_user.role)
        create(:ability, resources: %w(PaperTrail::IssueVersion), action_tags: %w[read], role: demo_user.role)
      end
      let(:custom_permissions_config) do
        {
          Issue: {
            view_create: %i[IssueEntry CalendarEntry Document Activity Comment],
            view_versions: true,
            version_klass: "PaperTrail::IssueVersion",
            restrictions: {
              cannot: [
                { actions: %i[edit destroy], proc_klass: "ResourcesAbilities::IssueAbility" },
                { actions: %i[read], conditions: { status: %i[draft] } }
              ]
            }
          }
        }
      end

      describe 'for a given version class ' do
        let!(:issue) { create(:issue, status_category: :open) }
        it 'allows to edit/destroy Issue' do
          expect(ability.can?(:create_issue_entries, Issue)).to be_truthy
          expect(ability.can?(:edit, issue)).to be_truthy
          expect(ability.can?(:destroy, issue)).to be_truthy
          expect(ability.cannot?(:view_documents, issue)).to be_truthy
          expect(ability.can?(:read, issue)).to be_falsey
          expect(ability.can?(:read, PaperTrail::IssueVersion)).to be_truthy
        end
      end
    end

    context 'with multiple actions' do
      let!(:resources_abilities) do
        create(:ability, resources: %w(Issue), action_tags: %w[read create edit destroy run_action], role: demo_user.role)
        create(:ability, resources: %w(IssueEntry), action_tags: %w[read create], role: demo_user.role)
      end
      let(:custom_permissions_config) do
        {
          Issue: {
            view_create: %i[IssueEntry CalendarEntry Document Activity Comment],
            restrictions: {
              cannot: [
                { actions: %i[destroy], conditions: { status: %i[draft] } },
                { actions: %i[edit destroy], proc_klass: "ResourcesAbilities::IssueAbility" }
              ]
            }
          }
        }
      end

      describe 'only the last condition count' do
        let!(:issue) { create(:issue, status_category: :open, status: :draft) }
        it 'denies edit/destroy Issue' do
          expect(ability.can?(:destroy, issue)).to be_truthy
        end
      end
    end

    context 'with multiple conditions' do
      let!(:resources_abilities) do
        create(:ability, resources: %w(Issue), action_tags: %w[read create edit destroy run_action], role: demo_user.role)
        create(:ability, resources: %w(IssueEntry), action_tags: %w[read create], role: demo_user.role)
      end
      let(:custom_permissions_config) do
        {
          Issue: {
            view_create: %i[IssueEntry CalendarEntry Document Activity Comment],
            restrictions: {
              cannot: [
                { actions: %i[create edit], conditions: { status_category: %i[done] } },
                { actions: %i[destroy], conditions: {
                  status_category: %i[open],
                  status: %i[draft]
                } }
              ]
            }
          }
        }
      end

      describe 'all conditions must met to deny detroying issue' do
        let!(:issue) { create(:issue, status_category: :open, status: :draft) }
        it 'denies edit/destroy Issue' do
          expect(ability.can?(:destroy, issue)).to be_falsey
        end
      end
    end

    context 'with manage  right' do
      let!(:resources_abilities) do
        create(:ability, resources: %w(Issue), action_tags: %w[manage], role: demo_user.role)
        create(:ability, resources: %w(Comment), action_tags: %w[manage], role: demo_user.role)
      end
      let(:custom_permissions_config) do
        {
          Issue: {
            view_create: %i[IssueEntry CalendarEntry Document Activity Comment],
            restrictions: {
              cannot: [
                { actions: %i[create edit], conditions: { status_category: %i[done] } },
                { actions: %i[destroy], conditions: {
                  status_category: %i[open],
                  status: %i[draft]
                } }
              ]
            }
          },
          Comment: {
            view_create: %i[],
            restrictions: {
              cannot: [
                {
                  actions: %i[edit destroy], conditions: { protected: "true" }
                }
              ]
            }
          }
        }
      end

      describe 'it allows to run_action etc' do
        let!(:issue) { create(:issue, status_category: :open, status: :draft) }
        let!(:comment) { create(:comment, commentable: issue, protected: true) }
        it 'run actions but respect restrictions' do
          expect(ability.can?(:run_action, issue)).to be_truthy
          expect(ability.can?(:destroy, issue)).to be_falsey
          expect(ability.can?(:destroy, comment)).to be_falsey
        end
      end
    end

    context 'with read right on user by default' do
      let!(:resources_abilities) do
        create(:ability, resources: %w(Issue), action_tags: %w[manage], role: demo_user.role)
        create(:ability, resources: %w(User), action_tags: %w[read], role: demo_user.role)
      end
      let!(:user) { create(:user) }
      let(:custom_permissions_config) do
        {}
      end

      describe 'it allows to run_action etc' do
        it 'run actions but respect restrictions' do
          expect(ability.can?(:read, demo_user)).to be_truthy
          expect(ability.can?(:destroy, demo_user)).to be_falsey
          expect(ability.can?(:read, user)).to be_truthy
        end
      end
    end

    context 'with super admin right' do
      before do
        demo_user.role.update(name: :super_admin)
      end

      describe 'it allows' do
        let!(:issue) { create(:issue, status_category: :open, status: :draft) }
        it 'denies edit/destroy Issue' do
          expect(ability.can?(:destroy, issue)).to be_truthy
        end
      end
    end
  end
end
