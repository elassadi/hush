module Concerns
  module IssueResources
    module NewFields
      extend ::Concerns::BaseFields

      def self.included(base)
        do_new_fields(base)
      end

      def self.do_new_fields(base)
        customer_field(base)
        repair_set_field(base)
        new_field(:input_device_heading, as: :heading, base:)
        new_field :hidden_selected_repair_set_id, as: :hidden, base:,
                                                  default: -> { params[:via_repair_set_id].presence || false }
        device_field(base)
        input_device_failure_categories_field(base)

        table_possible_repair_sets_field(base)
        new_field(:device_received, as: :boolean, base:)

        new_field :device_accessories_list, base:,
                                            as: :tags,
                                            suggestions: proc(self, :device_accessories_list_suggestions),
                                            close_on_select: true
        new_field(:additional_data_heading, as: :heading, base:)

        insurance_fields(base)

        new_field(:private_comment, as: :trix, stacked: true, attachment_key: :trix_attachments,
                                    placeholder: I18n.t('helpers.comment_tool.placeholder'), base:)
      end

      def self.insurance_fields(base)
        new_field :has_insurance_case,
                  as: :boolean, base:,
                  feature_required: :insurance,
                  default: false,
                  html: {
                    edit: { input: { data: { action: "issue-resource#onHasInsuranceCaseChanged" } } },
                    new: { input: { data: { action: "issue-resource#onHasInsuranceCaseChanged" } } }
                  }
        new_field(:insurance, as: :belongs_to, base:)
        new_field :insurance_number, as: :text, base:
      end

      def self.input_device_failure_categories_field(base)
        new_field :input_device_failure_categories,
                  base:,
                  as: :tags,
                  stimulus: { action: "issue-resource#onInputDeviceFailureCategoriesChanged", view: %i[new edit] },
                  suggestions: lambda {
                                 DeviceFailureCategory.cached_suggestions
                               }, enforce_suggestions: false, close_on_select: true,
                  default: lambda {
                             if params[:via_repair_set_id].present?
                               [RepairSet.by_account
                                         .find(params[:via_repair_set_id]).device_failure_category.name]
                             end
                           }
      end

      def self.device_field(base)
        new_field :device,
                  as: :belongs_to,
                  in_line: :create,
                  stimulus: { action: "issue-resource#onDeviceChange", view: %i[new edit] },
                  attach_scope:
                    lambda {
                      next query.none unless @parent.customer_id

                      devices_query = Device.by_account.where(id: @parent.customer.devices)

                      if @parent.device_id
                        devices_query.or(Device.by_account.where(id: @parent.device_id)).distinct
                      else
                        devices_query
                      end
                    },
                  base:
      end

      # def self.possible_repair_sets_field(base)
      #   new_field :possible_repair_sets, as: :select, multiple: true, base:, stacked: true, options: [],
      #                                    help: I18n.t('helpers.issue.possible_repair_sets')
      # end

      def self.table_possible_repair_sets_field(base)
        new_field :table_possible_repair_sets, as: :table, multiple: true, base:, stacked: true, options: [],
                                               help: I18n.t('helpers.issue.possible_repair_sets')
      end

      def self.repair_set_field(base)
        new_field :selected_repair_set,
                  as: :belongs_to, only_on: :new, base:,
                  searchable: true,
                  readonly: true,
                  default: lambda {
                             id = params[:via_repair_set_id].presence ||
                                  params[:issue][:hidden_selected_repair_set_id].presence
                             if id
                               RepairSet.by_account.find(id)
                             else
                               record.selected_repair_set
                             end
                           },
                  visible: lambda { |resource:|
                             resource.params[:via_repair_set_id].present? ||
                               resource.params.dig(:issue, :hidden_selected_repair_set_id).present?
                           }, help: I18n.t('helpers.issue.selected_repair_set')
      end

      def self.customer_field(base)
        new_field :customer, as: :belongs_to,
                             in_line: :create, searchable: true,
                             html: {
                               edit: { input: { data: { action: "issue-resource#onCustomerSelectChange" } } },
                               new: { input: { data: { action: "issue-resource#onCustomerSelectChange" } } }
                             }, hide_on: %i[show index], base:,
                             default: lambda {
                                        id = params[:via_customer_id].presence
                                        if id
                                          Customer.by_account.find(id)
                                        else
                                          record.customer
                                        end
                                      }
      end

      class << self
        def device_accessories_list_suggestions
          I18n.t('shared.device_accessories_list').map do |tag|
            { label: tag, value: tag }
          end
        end
      end
    end
  end
end
