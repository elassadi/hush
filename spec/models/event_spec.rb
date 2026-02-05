RSpec.describe Event, type: :model do
  include_context "setup system user"

  describe '#event_registered' do
    subject(:event) { create(:event, name: event_name) }

    context 'with existing event name' do
      let(:event_name) { "user_created" }

      it 'return true' do
        expect(event).to be_registered
        expect(event.klasses).to include Users::ActivatedEvent::SendResetPasswordInstructionsEmail
      end
    end

    context 'with a non existing event name' do
      let(:event_name) { :module_namespace_klass }

      it 'return true' do
        expect(event).not_to be_registered
      end
    end
  end
end
