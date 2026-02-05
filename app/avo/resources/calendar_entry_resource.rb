class CalendarEntryResource < ApplicationBaseResource
  include Concerns::ResourcesDefaultSetting.with_options(show_uuid: :show)
  include Concerns::AccountField

  STATUS_OPTIONS = {
    gray: %w[pending],
    info: %w[in_progress],
    success: %w[done],
    warning: %w[],
    danger: %w[canceld]
  }.freeze

  self.title = :name_of_calendarable
  self.stimulus_controllers = "calendar-entry-resource"
  self.model_class = ::CalendarEntry

  self.includes = %i[user customer]

  field :status, as: :status_badge, options: STATUS_OPTIONS, show_on_edit: true

  field :entry_type, as: :status_badge, options: STATUS_OPTIONS
  field :entry_type, as: :select, only_on: %i[new],
                     display_with_value: true, include_blank: true,
                     options: lambda { |_args|
                                ::CalendarEntry.human_enum_names(:entry_type, reject: %w[repair]).invert.sort
                              },
                     html: {
                       edit: { input: { data: { action: "calendar-entry-resource#onEntryTypeSelectChanged" } } },
                       new: { input: { data: { action: "calendar-entry-resource#onEntryTypeSelectChanged" } } }
                     }
  field :entry_type,
        as: :select, only_on: %i[edit],
        readonly: lambda {
                    @resource.record&.persisted? &&
                      !@resource.record.entry_type_regular? && !@resource.record.entry_type_repair?
                  },
        display_with_value: true, include_blank: true,
        options: lambda { |_args|
                   ::CalendarEntry.human_enum_names(:entry_type, reject: %w[user blocker repair]).invert.sort
                 },
        html: {
          edit: { input: { data: { action: "calendar-entry-resource#onEntryTypeSelectChanged" } } },
          new: { input: { data: { action: "calendar-entry-resource#onEntryTypeSelectChanged" } } }
        }
  with_options readonly: -> { @resource.record&.persisted? } do
    field :user, as: :belongs_to, searchable: true,
                 attach_scope: -> { Users::FetchByBranchQuery.call(branch: Current.user.branch).success },
                 hide_on: %i[index show]

    # For new records (no inline)
    field :customer, as: :belongs_to, searchable: true, in_line: :create,
                     hide_on: %i[index show]
    field :selected_repair_set, as: :belongs_to, searchable: true,
                                only_on: %i[new]
  end

  field :calendarable, as: :belongs_to, hide_on: %i[edit new],
                       polymorphic_as: :calendarable, searchable: true,
                       types: [::User, ::Issue, ::User]

  with_options readonly: -> { @resource.record&.status_canceld? } do
    field :category, as: :status_badge, options: STATUS_OPTIONS
    field :category, as: :select,
                     options: lambda { |_args|
                                ::CalendarEntry.human_enum_names(:category).invert.sort
                              },
                     display_with_value: true, include_blank: true,
                     hide_on: %i[index show]

    field :confirm_and_notify_customer, as: :boolean, only_on: %i[new], default: true
    field :notify_customer, as: :boolean, only_on: %i[edit]

    field :event,
          as: :dtime, format: "dd.LL.yyyy", picker_format: "d.m.Y",
          stacked: true,
          default: lambda {
            start_time = params[:start_time].presence
            end_time = params[:end_time].presence
            {
              start_date: start_time ? DateTime.parse(start_time) : @record.start_at || Time.zone.now,
              end_date: end_time ? DateTime.parse(end_time) : @record.end_at || 30.minutes.from_now
            }
          }
    field :all_day, as: :boolean, hide_on: %i[index],
                    default: lambda {
                               all_day = params[:all_day].presence
                               all_day ? all_day.to_boolean : @record.all_day
                             }, html: {
                               edit: { input: { data: { action: "calendar-entry-resource#onAllDayChanged" } } },
                               new: { input: { data: { action: "calendar-entry-resource#onAllDayChanged" } } }
                             }
    field :event_color, as: :color_picker, default: "#d1edbc", readonly: -> { @resource.record&.status_canceld? }
  end
  field :notes, stacked: true, as: :textarea, hide_on: %i[index]

  # width ia a css class #calendar_entry_color in core.css

  actions [
    CalendarEntries::CancelAction,
    CalendarEntries::ConfirmAction
  ]
end
