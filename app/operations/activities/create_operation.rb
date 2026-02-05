module Activities
  class CreateOperation < BaseOperation
    attributes :activityable, :activity_name, :activity_data, :owner_id

    def call
      result = create_activity
      activity = result.success
      if result.success?
        Event.broadcast(:activity_created, activity_id: activity.id)
        return Success(activity)
      end

      Failure(result.failure)
    end

    private

    def create_activity
      yield validate_statuses

      activity = Activity.create!(
        owner_id:,
        activityable:,
        metadata: {
          activity_data:,
          activity_name:
        },
        account: activityable.account
      )

      Success(activity)
    end

    def validate_statuses
      # unless activity.status_approved?
      #   return Failure("#{self.class} invalid_status Must be approved activity_id: #{activity.id} ")
      # end

      Success(true)
    end
  end
end
