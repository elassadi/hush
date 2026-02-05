module Concerns
  module IssueResources
    module EditFields
      extend ::Concerns::BaseFields

      def self.included(base)
        do_show_fields(base)
      end

      def self.do_show_fields(base)
        customer_field(base)
        edit_field(:input_device_heading, as: :heading, base:)
        device_field(base)
        input_device_failure_categories_field(base)
        table_possible_repair_sets_field(base)
        edit_field :device_received, as: :boolean, base:,
                                     visible: ->(resource:) { resource.record&.device_received? || false }

        edit_field :device_accessories_list, base:,
                                             as: :tags,
                                             visible: proc(self, :device_accessories_list_visibility),
                                             suggestions: proc(self, :device_accessories_list_suggestions),
                                             close_on_select: true
        edit_field(:additional_data_heading, as: :heading, base:)
        insurance_fields(base)
      end

      def self.insurance_fields(base)
        edit_field :has_insurance_case,
                   feature_required: :insurance,
                   as: :boolean, base:,
                   default: false,
                   html: {
                     edit: { input: { data: { action: "issue-resource#onHasInsuranceCaseChanged" } } },
                     new: { input: { data: { action: "issue-resource#onHasInsuranceCaseChanged" } } }
                   }
        edit_field(:insurance, as: :belongs_to, base:)
        edit_field :insurance_number, as: :text, base:
      end

      def self.input_device_failure_categories_field(base)
        edit_field(
          :input_device_failure_categories,
          base:,
          as: :tags,
          stimulus: { action: "issue-resource#onInputDeviceFailureCategoriesChanged", view: %i[new edit] },
          visible: proc(self, :input_device_failure_categories_visibility),
          suggestions: lambda {
                         DeviceFailureCategory.cached_suggestions
                       }, enforce_suggestions: false, close_on_select: true,
          default: lambda {
                     if params[:via_repair_set_id].present?
                       [RepairSet.by_account.find(params[:via_repair_set_id]).device_failure_category.name]
                     end
                   }
        )
      end

      def self.table_possible_repair_sets_field(base)
        edit_field :table_possible_repair_sets, as: :table, multiple: true, base:, stacked: true, options: [],
                                                help: I18n.t('helpers.issue.possible_repair_sets')
      end

      def self.device_field(base)
        edit_field :device, as: :belongs_to, in_line: :create, base:,
                            stimulus: { action: "issue-resource#onDeviceChange", view: %i[new edit] },
                            attach_scope: lambda {
                                            next query.none unless @parent.customer_id

                                            devices_query = Device.by_account.where(id: @parent.customer.devices)
                                            if @parent.device_id
                                              devices_query.or(Device.by_account.where(id: @parent.device_id)).distinct
                                            else
                                              devices_query
                                            end
                                          }
      end

      def self.customer_field(base)
        edit_field :customer, as: :belongs_to,
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
        def input_device_failure_categories_visibility(resource:)
          resource.view != :show || resource.record&.input_device_failure_categories.present? || false
        end

        def device_accessories_list_visibility(resource:)
          resource.view != :show || resource.record&.device_accessories_list.present? || false
        end

        def device_accessories_list_suggestions
          I18n.t('shared.device_accessories_list').map do |tag|
            { label: tag, value: tag }
          end
        end
      end
    end
  end
end
