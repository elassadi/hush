# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  BASIC_ACTIONS = %i(read create update destroy manage).freeze
  GLOBAL_ACTIONS = %i(send_user_notification).freeze

  AVAILABLE_RESOURCES =
    [
      "Ability",
      "Account",
      "Address",
      "ApiToken",
      "AppConfig",
      "Article",
      "ArticleGroup",
      # "Contact",
      "Comment",
      "Customer",
      "Device",
      "DeviceColor",
      "DeviceFailureCategory",
      "DeviceManufacturer",
      "DeviceModel",
      "Document",
      "Event",
      "EventJob",
      "Issue",
      "IssueEntry",
      "Merchant",
      "Notification",
      "PaperTrail::Version",
      "Role",
      "RepairSet",
      "RepairSetEntry",
      "Setting",
      "Stock",
      "StockArea",
      "StockLocation",
      "StockMovement",
      "Supplier",
      "SupplierArticle",
      "SupplierSource",
      "Template",
      "User",
      "WebhookRequest",
      "WebhookRequestJob"
    ].freeze

  ADMIN_ONLY_RESOURCES = %w[
    AppConfig
    ApiToken
    CorePolicy
    Event
    EventJob
    WebhookRequest
    WebhookRequestJob
  ].freeze
  AVAILABLE_RESOURCES_EXCEPT_ADMIN = AVAILABLE_RESOURCES - ADMIN_ONLY_RESOURCES

  WRITE_ACTIONS  = %w(attach detach create edit destroy).freeze
  ATTACH_ACTIONS = %w(attach detach).freeze

  class << self
    def available_resources
      # avo_resources = Avo::App.valid_resources.map do |r|
      #   [r.model_class.model_name.to_s, r.model_class.model_name.to_s]
      # end
      avo_resources = AVAILABLE_RESOURCES_EXCEPT_ADMIN.map { |r| r }
      avo_resources << "*"

      avo_resources.sort
    end

    def available_actions(record = nil)
      actions = ApplicationPolicy::BASIC_ACTIONS
      return actions unless record&.resource

      actions += record.resource.constantize.available_actions unless record.resource.casecmp("*").zero?

      actions
    end
  end
end
