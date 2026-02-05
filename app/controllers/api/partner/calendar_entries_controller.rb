module Api
  module Partner
    class CalendarEntriesController < ::Api::Partner::BaseController
      SLOT_DURATION = 30 # minutes
      def _index
        models = RepairSet.by_account.all
        models = models.where(device_model_id: params[:device_model_id]) if params[:device_model_id].present?
        models = models.where('name LIKE ?', "%#{params[:search_term]}%") if params[:search_term].present?
        render json: models
      end

      def available_slots
        slot_duration = SLOT_DURATION.minutes
        start_date = validated_start_date

        end_date = params[:end_date].present? ? params[:end_date].to_date : start_date
        merchant_id = params[:merchant_id] || Current.user.branch.id
        days_only = params[:days_only] || false
        result = CalendarEntries::AvailableSlotsOperation.call(start_date:, end_date:, slot_duration:,
                                                               merchant_id:, days_only:)
        if result.success?
          render json: result.success
        else
          render json: { errors: result.failure }, status: :unprocessable_entity
        end
      end

      private

      def validated_start_date
        start_date = params[:start_date].to_date
        minimum_start_date = Time.zone.today +
                             (Current.account.booking_settings.booking_lead_time_min.to_i).days
        [start_date, minimum_start_date].max
      end
    end
  end
end
