class CommentResource < ApplicationBaseResource
  include Concerns::AccountField
  include Concerns::DateResourceSidebar

  self.title = :clean_mini_teaser
  self.authorization_policy = GlobalDataAccessPolicy
  self.translation_key = "activerecord.attributes.#{to_s.underscore.gsub(/_resource/, '')}"

  STATUS_OPTIONS = {
    gray: %w[unknown],
    info: %w[],
    success: %w[paid],
    warning: %w[refunded],
    danger: %w[unknown]
  }.freeze

  self.includes = []

  field :uuid, as: :uuid, hide_on: :index
  field :commentable, as: :belongs_to, polymorphic_as: :commentable, types: [
    ::Supplier, ::Customer, ::Merchant, ::Contact, ::Issue, ::PurchaseOrder
  ], searchable: true

  field :notify_customer_with, as: :select, only_on: [:new],
                               options: lambda { |_args|
                                          options = ::Comment.human_enum_names(:notify_customer_with).invert

                                          options.reject do |_, value|
                                            next false if value == "none"

                                            ApplicationSetting.customer_notification_for(
                                              trigger: :comment_created, channel: value
                                            ).blank?
                                          end
                                        },
                               display_with_value: true,
                               visible: lambda { |resource:|
                                          return false unless resource

                                          ApplicationSetting.customer_notification_for(
                                            trigger: :comment_created
                                          ).present?
                                        }
  field :body, always_show: true, as: :trix, stacked: true, show_on: :all, attachment_key: :trix_attachments,
               help: I18n.t('helpers.comment_tool.how_to_use_tips'),
               placeholder: I18n.t('helpers.comment_tool.placeholder'), name: ""
  # field :teaser, as: :text, only_on: :index, as_html: true, format_using: lambda { |value|
  #                                                                           "<div class='trix-content'>#{value}</div>"
  #                                                                         }
  field :owner, as: :belongs_to,  only_on: :index
  field :body, as: :text, only_on: :index, as_html: true, format_using: lambda { |value|
    "<div class='trix-content'>#{value}</div>"
  }
end
