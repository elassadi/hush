module RequestHeaderHelper
  extend ActiveSupport::Concern

  included do
    include_context 'with authenticated user header informations', type: :request
  end
end
