module Api
  module Partner
    class MerchantsController < ::Api::Partner::BaseController
      def branches
        render json: Current.account.branches.map { |s|
                       { name: s.title, id: s.id, address: s.primary_address&.one_liner }
                     }
      end
    end
  end
end
