class IssueResource < ApplicationBaseResource
  include Concerns::AccountField
  MAX_DEVICES_TO_SHOW = 10

  STATUS_OPTIONS = {
    light: %w[awaiting_device],
    gray: %w[draft open awaiting_approval],
    info: %w[in_progress ready_to_repair repairing],
    success: %w[done completed repairing_successfull repairing_successfull],
    warning: %w[awaiting_parts],
    danger: %w[canceld repairing_unsuccessfull]
  }.freeze

  self.title = :title
  self.translation_key = "activerecord.attributes.issue"
  self.stimulus_controllers = "issue-resource commentable entries-summary-tool read-only-patternlock"
  self.model_class = ::Issue
  self.includes = [:customer, { device: %i[device_model device_color device_manufacturer] }]
  self.resolve_query_scope = lambda { |model_class:|
    model_class.order(created_at: :desc)
  }
  self.authorization_policy = ::MerchantDataAccessPolicy

  self.search_query = lambda {
    ResourceHelpers::SearchEngine.call(
      search_query: params[:q], global: params[:global].to_boolean, scope:,
      model: :issue, fetch_recent: true
    ).success
  }

  field :search_issue_name, as: :text, hide_on: :all, as_label: true do |model|
    str = ""
    if model.customer
      str = "#{::Customer.human_enum_name(:salutation, model.customer.salutation)} #{model.customer.title}"
    end
    str += " [#{model.device&.name}]" if model.device
    str
  end

  field :search_issue_description, as: :text, hide_on: :all, as_description: true do |model|
    str = ""
    if model.customer
      str += " #{model.customer.primary_address&.one_liner}" if model.customer.primary_address
      String(str).truncate 130
    end

    "#{str} (#{model.title})"
  end

  self.show_controls = lambda {
    back_button
    delete_button
    link_to "", "/resources/comments/new?modal_resource=true&via_child_resource=CommentResource" \
                "&via_relation=commentable&via_relation_class=Issue&via_resource_id=#{params[:id]}",
            icon: "heroicons/outline/chat",
            style: :primary, color: :primary,
            data: { turbo_frame: "modal_resource" }

    # if record.locked?
    #   action Issues::UnlockAction, style: :primary, color: :red, icon: "heroicons/solid/lock-closed", label: "",
    #                                title: I18n.t("activerecord.attributes.issue.unlock")

    # else
    #   action Issues::LockAction, style: :primary, color: :green, icon: "heroicons/solid/lock-open", label: "",
    #                              title: I18n.t("activerecord.attributes.issue.lock")
    # end
    # items = actions_list exclude: [Issues::WorkflowAction, Issues::DoneRepairingAction, Issues::StartRepairingAction]

    # if current_user.can?(:edit_workflow, record)
    #   if record.can_run_event?(:start_repairing)
    #     action Issues::StartRepairingAction, style: :primary, color: :primary, icon: "heroicons/outline/play"
    #   end

    #   if record.workflow.repairing_completed?
    #     if current_user.may?(:complete, resource.model)
    #       action Issues::CompleteAction, style: :primary, color: :green, icon: "heroicons/solid/stop"
    #     end
    #   else
    #     if record.can_run_event?(:stop_repairing)
    #       action Issues::StopRepairingAction, style: :primary, color: :red, icon: "heroicons/outline/pause"
    #     end
    #     if record.can_run_event?(:done_repairing_successfull)
    #       action Issues::DoneRepairingAction, style: :primary, color: :green, icon: "heroicons/outline/check-circle"
    #     end
    #   end
    # end

    # if current_user.can?(:edit_workflow, record) && Issues::B2cWorkflow.human_workflow_event_names(record).any?
    #   action Issues::WorkflowAction, style: :primary, color: :primary, icon: "heroicons/outline/cog-6-tooth"
    # end
    # edit_button if current_user.can?(:edit, record)
    # items
  }

  include Concerns::IssueResources::ShowFields
  include Concerns::IssueResources::IndexFields
  include Concerns::IssueResources::NewFields
  include Concerns::IssueResources::EditFields

  field :issue_entries,
        as: :has_many, modal_create: true, hide_search_input: true, discreet_pagination: true,
        scope: lambda {
          query.not_category_rabatt.reorder(sort_repair_set_id: :asc,
                                            repair_set_entry_id: :asc, created_at: :desc)
        }

  tool EntriesSummaryTool

  field :comments, as: :has_many, modal_create: true, attach_scope: lambda {
    query.none
  }
  tool IssueReloadTool

  tabs do
    translation_key = "activerecord.attributes.document"
    tab ->  { I18n.t(:other, scope: translation_key) } do
      field :documents, as: :has_many, use_resource: DocumentResource, hide_search_input: true,
                        discreet_pagination: true,
                        translation_key:
    end

    tab lambda {
          # counter = if (issue = Issue.find_by(id: params[:id]))
          #             " (#{issue.calendar_entries.count})"
          #           end
          # I18n.t('activerecord.attributes.calendar_entry.other') + counter.to_s
          I18n.t('activerecord.attributes.calendar_entry.other')
        } do
      field :calendar_entries, as: :has_many, hide_search_input: true, discreet_pagination: true,
                               use_resource: IssueCalendarEntryResource, modal_create: false,
                               translation_key: :'activerecord.attributes.calendar_entry'
    end

    tab lambda {
          # counter = if (issue = Issue.find_by(id: params[:id]))
          #             " (#{issue.activities.count})"
          #           end
          # I18n.t('activerecord.attributes.activity.other') + counter.to_s
          I18n.t('activerecord.attributes.activity.other')
        } do
      field :activities, as: :has_many, translation_key: :'activerecord.attributes.activity'
    end
  end
  field :versions, as: :has_many, use_resource: IssueVersionResource, readonly: true,
                   scope: -> { query.reorder(created_at: :desc) },
                   visible: ->(resource:) { Current.user.admin? || Rails.env.development? }

  field :via_cloned_id, as: :hidden, default: -> { params[:via_cloned_id].presence || false }

  actions(::CloneAction)

  filter ::BaseStatusFilter, arguments: { model_class: Issue, status_field_name: :status_category }
  filter Issues::StatusFilter
  filter Issues::CanceldFilter
end
