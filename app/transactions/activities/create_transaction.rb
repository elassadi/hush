module Activities
  class CreateTransaction < BaseTransaction
    attributes :activityable, :activity_name, :activity_data, :owner_id

    def call
      activity = ActiveRecord::Base.transaction do
        yield create_activity.call(activityable:,
                                   activity_name:, activity_data:, owner_id:)
      end
      Success(activity)
    rescue Dry::Monads::Do::Halt => e
      ErrorTracking.capture_message(
        "#{self.class.name} for activity failed with #{e.result.failure}"
      )
      raise
    end

    private

    def create_activity = Activities::CreateOperation
  end
end
