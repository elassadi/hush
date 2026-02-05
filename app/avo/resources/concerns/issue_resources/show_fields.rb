module Concerns
  module IssueResources
    module ShowFields
      extend ::Concerns::BaseFields
      STATUS_OPTIONS = {
        light: %w[awaiting_device awaiting_approval],
        gray: %w[draft open],
        info: %w[in_progress ready_to_repair repairing],
        success: %w[done completed repairing_successfull repairing_successfull],
        warning: %w[awaiting_parts],
        danger: %w[canceld repairing_unsuccessfull]
      }.freeze

      def self.included(base)
        do_show_fields(base)
        do_show_sidebar(base, self)
      end

      def self.do_show_fields(base)
        show_field(:sequence_id, as: :uuid, only_on: :show, base:)

        show_field(:merchant, as: :belongs_to, visible: proc(self, :merchant_visibility), base:)
        show_field(:status, as: :status_badge, options: STATUS_OPTIONS, shorten: false, base:)
        show_field :status_category, as: :status_badge, options: STATUS_OPTIONS, base:,
                                     visible: proc(self, :status_category_visibility)
        show_field(:customer, as: :belongs_to, base:)
        show_field(:input_device_heading, as: :heading, base:)
        show_field :imei, as: :uuid, base:, visible: proc(self, :imei_visibility)
        show_field(:device, as: :belongs_to, base:)
        show_field :input_device_failure_categories, as: :tags, base:,
                                                     visible: proc(self, :input_device_failure_categories_visibility)
        show_field(:device_received, as: :boolean, base:, visible: proc(self, :device_received_visibility))
        show_field :device_accessories_list,
                   base:,
                   as: :tags, close_on_select: true,
                   visible: proc(self, :device_accessories_list_visibility),
                   suggestions: proc(self, :device_accessories_list_suggestions)

        show_field(:additional_data_heading, as: :heading, base:)
        show_field :assignee, as: :belongs_to, base:, visible: proc(self, :assignee_visibility)
        show_field(:owner, as: :belongs_to, base:)
        show_field :request_approved, as: :boolean, base:, visible: proc(self, :request_approved_visibility)
        show_field :device_repaired, as: :boolean, base:, visible: proc(self, :device_repaired_visibility)

        show_field :has_insurance_case, as: :boolean, base:, visible: proc(self, :insurance_case_visibility?)
        show_field :repair_report_content, as: :trix, base:, stacked: true, always_show: true,
                                           visible: proc(self, :repair_report_content_visibility)

        %i(created_at updated_at).each do |field_name|
          show_field field_name, as: :date_time, show_seconds: true, base:,
                                 name: I18n.t("shared.#{field_name}")
        end
        base.field :scheduled_repair_at, as: :text, as_html: true, base:, only_on: :show,
                                         visible: proc(self, :scheduled_repair_at_visibility),
                   &proc(self, :scheduled_repair_at_renderer)
      end

      def self.do_show_sidebar(base, context)
        base.sidebar do
          field :gsm_path, as: :text,
                           as_html: true,
                           only_on: :show,
                           label: "ss",
                           name: "&nbsp;".html_safe,
                           visible: context.proc(context, :gsm_path_visibility),
                &context.proc(context, :gsm_path_renderer)
          with_options only_on: :show, visible: context.proc(context, :insurance_visibility) do
            field :insurance, as: :belongs_to, name: I18n.t("activerecord.attributes.issue.insurance")
            field :insurance_number, as: :text, name: I18n.t("activerecord.attributes.issue.insurance_number")
          end

          show_field :unlock_pin, as: :text, base: binding.receiver,
                                  name: I18n.t("activerecord.attributes.device.unlock_pin"),
                                  visible: context.proc(context, :unlock_pin_visibility)

          field :unlock_pattern, label: false, stacked: true, as: :text, base: binding.receiver,
                                 name: I18n.t("activerecord.attributes.device.unlock_pattern"),
                                 visible: context.proc(context, :unlock_pattern_visibility),
                                 as_html: true,
                                 only_on: :show,
                &context.proc(context, :unlock_pattern_renderer)

          # for some reason the side bar the show_field is not working
          field :comments_side_bar,
                label: false, stacked: true, as: :text, only_on: :show,
                name: I18n.t("activerecord.attributes.comment.other"),
                as_html: true,
                &context.proc(context, :comments_renderer)
        end
      end

      class << self
        # rubocop:disable Lint/UnusedMethodArgument
        def merchant_visibility(resource:)
          true
        end
        # rubocop:enable Lint/UnusedMethodArgument

        def customer_default
          id = params[:via_customer_id].presence
          if id
            Customer.by_account.find(id)
          else
            record.customer
          end
        end

        def status_category_visibility(resource:)
          return false if resource.record.nil?

          resource.record&.status != "completed"
        end

        def imei_visibility(resource:)
          return false if resource.record.nil?

          resource.record.imei.present?
        end

        def input_device_failure_categories_visibility(resource:)
          return false if resource.record.nil?

          resource.record.input_device_failure_categories.present?
        end

        def device_received_visibility(resource:)
          return false if resource.record.nil?

          resource.record.device_received?
        end

        def device_accessories_list_visibility(resource:)
          return false if resource.record.nil?

          resource.record.device_accessories_list.present?
        end

        def device_accessories_list_suggestions
          I18n.t('shared.device_accessories_list').map do |tag|
            { label: tag, value: tag }
          end
        end

        # def assignee_scope(resource:)
        #   query.by_account.joins(:role).where(roles: { name: "technician" })
        # end

        def assignee_visibility(resource:)
          return false if resource.record.nil?

          resource.record.assignee.present?
        end

        def request_approved_visibility(resource:)
          return false if resource.record.nil?

          resource.record.request_approved?
        end

        def device_repaired_visibility(resource:)
          return false if resource.record.nil?

          resource.record.device_repaired?
        end

        def insurance_case_visibility?(resource:)
          return false if resource.record.nil?

          resource.record.has_insurance_case?
        end

        def repair_report_content_visibility(resource:)
          return false if resource.record.nil?

          resource.record.repair_report_content.present?
        end

        def gsm_path_visibility(resource:)
          return false if resource.record.nil?

          resource.view == :show && resource.record.device && resource.record.device.gsm_path.present?
        end

        def gsm_path_renderer(record, _resource, _view, _field)
          return if record.device.blank? || record.device.gsm_path.blank?

          %{
              <img src="#{record.device.device_model.gsm_path}" alt=""
              style="max-width: 300px;max-height: 150px;margin: auto;">
            }
        end

        def insurance_visibility(resource:)
          return false if resource.record.nil?

          resource.record.has_insurance_case?
        end

        def unlock_pin_visibility(resource:)
          return false if resource.record.nil?

          resource.record.unlock_pin.present?
        end

        def unlock_pattern_visibility(resource:)
          return false if resource.record.nil?

          resource.record.unlock_pattern.present?
        end

        def scheduled_repair_at_visibility(resource:)
          return false if resource.record.nil?

          resource.record.scheduled_repair_at.present?
        end

        def unlock_pattern_renderer(_record, resource, _view, _field)
          html = %{
              <div class="flex flex-row justify-center items-center " id="lockwrapper" >
                <div class="w-24" style="width: 150px">
                  <svg class="patternlock" id="lock" viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
                    <g class="lock-actives"></g>
                    <g class="lock-lines"></g>
                    <g class="lock-dots">
                        <circle cx="20" cy="20" r="2"/>
                        <circle cx="50" cy="20" r="2"/>
                        <circle cx="80" cy="20" r="2"/>

                        <circle cx="20" cy="50" r="2"/>
                        <circle cx="50" cy="50" r="2"/>
                        <circle cx="80" cy="50" r="2"/>

                        <circle cx="20" cy="80" r="2"/>
                        <circle cx="50" cy="80" r="2"/>
                        <circle cx="80" cy="80" r="2"/>
                    </g>
                  </svg>
                </div>
              </div>
            }
          code = resource.model.unlock_pattern.presence
          if code.present? && code.to_s.match?(/\A[1-9]+\z/)
            html + "<input type='hidden' data-read-only-patternlock-target='unlockPatternHiddenInput' " \
                   "value='#{resource.model.unlock_pattern}' />"
          else
            resource.model.unlock_pattern.presence
          end
        end

        def comments_renderer(record, _resource, _view, _field)
          url = "/commentable?turbo_frame=commentable&amp;via_resource_class=IssueResource&amp;via_resource_id="
          %{
                <turbo-frame
                  id="commentable"  src="#{url}#{record.id}" target="_top">
                </turbo-frame>
          }
        end

        def scheduled_repair_at_renderer(record, _resource, _view, _field)
          return if record.blank? || record.scheduled_repair_at.blank?

          date = I18n.l(record.scheduled_repair_at, format: :short)
          # id = record.most_recent_calendar_entry.id
          duration_in_seconds = record.most_recent_calendar_entry.end_at - record.most_recent_calendar_entry.start_at

          # Convert duration to hours and minutes
          hours = (duration_in_seconds / 3600).to_i
          minutes = ((duration_in_seconds % 3600) / 60).to_i

          human_readable_duration = "#{hours}Std. #{minutes} Min."
          # Avo::App.view_context.link_to(
          #   "#{date}, Dauer: #{human_readable_duration} ",
          #   "/calendar_tool/?calendar_entry_id=#{id}",
          #   target: "calendar_tab"
          # )
          "#{date}, Dauer: #{human_readable_duration}"
        end
      end
    end
  end
end
