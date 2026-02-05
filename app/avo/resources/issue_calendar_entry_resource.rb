class IssueCalendarEntryResource < ApplicationBaseResource
  include Concerns::ResourcesDefaultSetting
  include Concerns::AccountField

  STATUS_OPTIONS = {
    gray: %w[pending],
    info: %w[in_progress],
    success: %w[done],
    warning: %w[],
    danger: %w[canceld]
  }.freeze

  self.title = :id
  self.includes = []
  self.authorization_policy = GlobalDataAccessPolicy
  self.stimulus_controllers = "issue-calendar-entry-resource embedded-calendar"
  self.model_class = CalendarEntry

  self.includes = []

  field :status, as: :status_badge, options: STATUS_OPTIONS
  with_options readonly: -> { record && record.persisted? } do
    field :calendarable, as: :belongs_to,
                         polymorphic_as: :calendarable, searchable: true,
                         types: [::Issue]

    field :entry_type, as: :status_badge, options: STATUS_OPTIONS, shorten: false
  end
  field :entry_type, as: :select, hide_on: %i[index],
                     display_with_value: true, include_blank: true,
                     options: lambda { |_args|
                                ::CalendarEntry.human_enum_names(:entry_type, reject: %i[user blocker])
                                               .invert.sort
                              }

  field :event, as: :dtime, default: lambda {
    {
      start_date: @record.start_at || Time.zone.now,
      end_date: @record.end_at || 30.minutes.from_now
    }
  }

  field :notes, as: :textarea, hide_on: %i[index]

  # width ia a css class #calendar_entry_color in core.css
  field :event_color, as: :color_picker, default: "#d1edbc"

  field :start_at, as: :hidden do |record|
    record.start_at&.iso8601
  end
  field :created_at, as: :date_time, show_seconds: true, only_on: %i[show]
  field :updated_at, as: :date_time, show_seconds: true, only_on: %i[show]

  actions [
    IssueCalendarEntries::CancelAction,
    IssueCalendarEntries::ConfirmAction
  ]

  sidebar do
    heading '<div  id="embedded-calendar"' \
            'class="embedded-issue-calendar" style="height: 800px;" ></div>',
            as_html: true,
            visible: ->(resource:) { !resource.model&.status_canceld? }
  end
end
