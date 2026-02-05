RSpec.shared_context 'with authenticated user header informations' do
  let(:HTTP_AUTHENTICATED_USERID) { current_user.reference_id }
  let(:HTTP_AUTHENTICATED_SCOPE) { current_user.type }
end
