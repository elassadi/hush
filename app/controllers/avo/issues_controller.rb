# This controller has been generated to enable Rails' resource routes.
# You shouldn't need to modify it in order to use Avo.

module Avo
  class IssuesController < BaseResourceController
    def table_possible_repair_sets
      return render_edit_table_possible_repair_sets if params[:id].present?
      return render_new_table_possible_repair_sets if params[:device_id].present?

      respond_to do |format|
        format.turbo_stream do
          render :table_possible_repair_sets, locals: {
            rows: [],
            columns: [],
            field: table_possible_repair_sets_field
          }
        end
      end
    end

    def preview_document
      respond_to do |format|
        format.turbo_stream do
          render :preview_document, locals: { document_url: }
        end
      end
    end

    def show
      RecentSearchItems::SaveOperation.call(model: @model)
      super
    end

    def create
      result = super
      via_cloned_id = params.dig(:issue, :via_cloned_id)
      clone_issue_entries(via_cloned_id.to_i) if via_cloned_id.present? && @model.persisted?
      result
    end

    private

    # def render_new_table_possible_repair_sets
    #   if params[:device_failure_categories].present?
    #     device_failure_categories = params[:device_failure_categories].split(",").map(&:strip)
    #   end

    #   device = Device.by_account.find(params[:device_id])
    #   query = matching_scope(
    #     account: Current.account,
    #     input_device_failure_category_name: device_failure_categories,
    #     device_model: device.device_model,
    #     device_color: device.device_color
    #   )
    #   rows = query.map do |repair_set|
    #     {
    #       id: repair_set.id,
    #       name: repair_set.name,
    #       status: repair_set.stock_status,
    #       selected: false,
    #       price: repair_set.price
    #     }
    #   end

    #   respond_to do |format|
    #     format.turbo_stream do
    #       render :table_possible_repair_sets, locals: {
    #         rows:,
    #         columns: table_columns,
    #         field: table_possible_repair_sets_field
    #       }
    #     end
    #   end
    # end

    # def table_columns
    #   [
    #     { header: I18n.t("activerecord.attributes.issue.status").capitalize,
    #       id: :status, render_partial: 'avo/issues/table_possible_repair_sets_status' },
    #     { header: 'Name',
    #       id: :name },
    #     { header: I18n.t("activerecord.attributes.issue.price").capitalize,
    #       id: :price,
    #       render_partial: 'avo/issues/table_possible_repair_sets_price' }
    #   ]
    # end

    # def render_edit_table_possible_repair_sets
    #   issue = Issue.by_account.find(params[:id])

    #   device = issue.device

    #   device = Device.by_account.find(params[:device_id]) if params[:device_id].present?

    #   device_failure_categories = issue.input_device_failure_categories unless params.key?(:device_failure_categories)

    #   if params[:device_failure_categories].present?
    #     device_failure_categories = params[:device_failure_categories].split(",").map(&:strip)
    #   end

    #   query = matching_scope(
    #     account: Current.account,
    #     input_device_failure_category_name: device_failure_categories,
    #     device_model: device.device_model,
    #     device_color: device.device_color
    #   )
    #   repair_set_ids = issue.repair_set_ids

    #   rows = query.map do |repair_set|
    #     {
    #       id: repair_set.id,
    #       name: repair_set.name,
    #       status: repair_set.stock_status,
    #       selected: repair_set_ids.include?(repair_set.id),
    #       price: repair_set.price
    #     }
    #   end

    #   respond_to do |format|
    #     format.turbo_stream do
    #       render :table_possible_repair_sets, locals: {
    #         rows:,
    #         columns: table_columns,
    #         field: table_possible_repair_sets_field
    #       }
    #     end
    #   end
    # end

    def render_new_table_possible_repair_sets
      device_failure_categories = extract_device_failure_categories(params[:device_failure_categories])
      device = Device.by_account.find(params[:device_id])

      rows = build_rows(device:, device_failure_categories:, selected_ids: [])

      respond_to_table(rows)
    end

    def render_edit_table_possible_repair_sets
      issue = Issue.by_account.find(params[:id])
      device = issue.device
      device = Device.by_account.find(params[:device_id]) if params[:device_id].present?
      device_failure_categories = if params.key?(:device_failure_categories)
                                    extract_device_failure_categories(params[:device_failure_categories])
                                  else
                                    issue.input_device_failure_categories
                                  end

      rows = build_rows(device:, device_failure_categories:, selected_ids: issue.repair_set_ids)
      respond_to_table(rows)
    end

    def extract_device_failure_categories(categories)
      categories.present? ? categories.split(",").map(&:strip) : []
    end

    def build_rows(device:, device_failure_categories:, selected_ids:)
      query = matching_scope(
        account: Current.account,
        input_device_failure_category_name: device_failure_categories,
        device_model: device.device_model,
        device_color: device.device_color
      )

      query.map do |repair_set|
        {
          id: repair_set.id,
          name: repair_set.name,
          status: repair_set.stock_status,
          selected: selected_ids.include?(repair_set.id),
          price: repair_set.price
        }
      end
    end

    def respond_to_table(rows)
      respond_to do |format|
        format.turbo_stream do
          render :table_possible_repair_sets, locals: {
            rows:,
            columns: table_columns,
            field: table_possible_repair_sets_field
          }
        end
      end
    end

    def table_columns
      [
        { header: I18n.t("activerecord.attributes.issue.status").capitalize,
          id: :status, render_partial: 'avo/issues/table_possible_repair_sets_status' },
        { header: 'Name', id: :name },
        { header: I18n.t("activerecord.attributes.issue.price").capitalize, id: :price,
          render_partial: 'avo/issues/table_possible_repair_sets_price' }
      ]
    end

    def matching_scope(account:, input_device_failure_category_name:, device_model:, device_color: nil)
      query = RepairSet.where(account:, device_model:).order(:name)

      if input_device_failure_category_name.present?
        query = query.where(
          device_failure_category: DeviceFailureCategory.by_account.where(name: input_device_failure_category_name)
        )
      end

      if query.where(device_color:).count.positive?
        query.where(device_color: [nil, device_color])
      else
        query
      end
    end

    def table_possible_repair_sets_field
      issue_resource = ::Avo::App.get_resource_by_model_name("Issue")
      issue_resource.get_field_definitions.find { |f| f.id.to_s == "table_possible_repair_sets" }
    end

    def document_url
      issue = Issue.by_account.find(params[:id])
      result  = Issues::PreviewDocumentOperation.call(issue:, document_type: params[:document_type])
      return unless result.success?

      document = result.success
      document.download_url
    end

    def clone_issue_entries(via_cloned_id)
      cloned_issue = Issue.by_account.find(via_cloned_id)
      cloned_issue.issue_entries.each do |entry|
        @model.issue_entries.create(entry.attributes.except("id", "issue_id", "uuid"))
      end
    end

    def save_model
      return super unless requires_custom_save?

      assign_possible_repair_sets ||  assign_selected_repair_set

      @view == :create ? create_issue : update_issue
    end

    def requires_custom_save?
      @view.in? %i[create update]
    end

    def assign_possible_repair_sets_as_select_input
      possible_repair_sets = params.dig(:issue, :possible_repair_sets)
      if possible_repair_sets.present? && possible_repair_sets.reject(&:empty?).present?
        @model.possible_repair_sets = possible_repair_sets.reject(&:empty?)
        return true
      end
      false
    end

    def assign_possible_repair_sets
      possible_repair_sets = params.dig(:issue, :table_possible_repair_sets)
      if possible_repair_sets.present? && possible_repair_sets.reject(&:empty?).present?
        @model.possible_repair_sets = possible_repair_sets.reject(&:empty?)
        return true
      end
      false
    end

    def assign_selected_repair_set
      return if params.dig(:issue, :hidden_selected_repair_set_id).blank?

      @model.selected_repair_set_id = params[:issue][:hidden_selected_repair_set_id]
    end

    def create_issue
      result = Issues::CreateTransaction.call(issue_attributes:)
      if result.success?
        @model = result.success
        return true
      end
      if result.failure.is_a?(Issue)
        @model = result.failure
      else
        @errors = Array.wrap([result.failure, @model.errors.full_messages].flatten).compact
      end
      nil
    end

    def update_issue
      result = Issues::UpdateTransaction.call(issue_id: @model.id, issue_attributes:)
      if result.success?
        @model = result.success
        return true
      end
      if result.failure.is_a?(Issue)
        @model = result.failure
      else
        @errors = Array.wrap([result.failure, @model.errors.full_messages].flatten).compact
      end
      nil
    end

    def issue_attributes
      @model.attributes.slice(
        *%w[device_id customer_id assignee_id]
      ).merge(
        input_device_failure_categories: @model.input_device_failure_categories,
        device_accessories_list: @model.device_accessories_list,
        device_received: @model.device_received?,
        selected_repair_set_id: @model.selected_repair_set_id,
        possible_repair_sets: @model.possible_repair_sets,
        private_comment: @model.private_comment,
        has_insurance_case: @model.has_insurance_case,
        insurance_id: @model.insurance_id,
        insurance_number: @model.insurance_number
      )
    end
  end
end
