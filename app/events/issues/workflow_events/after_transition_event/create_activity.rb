module Issues
  module WorkflowEvents
    module AfterTransitionEvent
      class CreateActivity < BaseWorkflowEvent
        subscribe_to :after_transition
        attributes :resource_id, :resource_class, :from, :to,
                   :triggering_event, :event_args
        optional_attributes :current_user_id

        def call
          create_activity
        end

        private

        def create_activity
          activity_name = "workflow_transition"

          activity = yield Activities::CreateTransaction.call(
            activityable:, activity_name:,
            activity_data:,
            owner_id: current_user_id
          )
          Success(activity)
        end

        def activityable
          resource_class.constantize.find(resource_id)
        end

        def activity_data
          {
            from:,
            to:,
            triggering_event:,
            event_args:
          }
        end
      end
    end
  end
end
