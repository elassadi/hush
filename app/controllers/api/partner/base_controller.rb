module Api
  module Partner
    class BaseController < Api::BaseController
      before_action :ensure_b2b_enabled

      def ensure_b2b_enabled
        # raise ActionController::RoutingError, 'Not Found' if ENV["B2B_ENABLED"].blank?
      end
    end
  end
end
