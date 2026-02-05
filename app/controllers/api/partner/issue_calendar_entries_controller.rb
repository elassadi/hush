module Api
  module Partner
    class IssueCalendarEntriesController < ::Api::Partner::BaseController
      def create
        Current.user.authorize!(:create, CalendarEntry)

        result = IssueCalendarEntries::Api::CreateTransaction.call(params: params_hsh)
        if result.success?
          entry = result.success
          render json: entry, status: :created
        else
          render json: { errors: result.failure }, status: :unprocessable_entity
        end
      end

      private

      def params_hsh
        return params_hash_dev if Rails.env.development?

        hsh = {
          entry_type: "repair",
          start_at: params[:start_at],
          end_at: params[:end_at],
          merchant_id: params[:merchant_id],
          customer: {
            first_name: params.dig(:customer, :first_name),
            last_name: params.dig(:customer, :last_name),
            email: params.dig(:customer, :email),
            mobile_number: params.dig(:customer, :mobile_number),
            salutation: params.dig(:customer, :salutation)
          }
        }
        hsh[:repair_set_id] = params[:repair_set_id] if params[:repair_set_id].present?
        hsh[:notes] = params[:notes] if params[:notes].present?
        hsh[:article_skus] = params[:article_skus] if params[:article_skus].present?
        hsh
      end

      def params_hash_dev
        hsh = {
          entry_type: "repair",
          start_at: params[:start_at],
          end_at: params[:end_at],
          merchant_id: params[:merchant_id],
          customer: {
            first_name: Faker::Name.first_name,
            last_name: Faker::Name.last_name,
            email: "mohamed.elassadi+#{rand(100_000)}@gmail.com",
            mobile_number: "017611212#{rand(100_000)}",
            salutation: params.dig(:customer, :salutation)
          },
          notes: params[:notes].presence || "this is test notes"
        }
        hsh[:repair_set_id] = params[:repair_set_id] if params[:repair_set_id].present?
        hsh[:article_skus] = params[:article_skus] if params[:article_skus].present?
        hsh
      end
    end
  end
end
