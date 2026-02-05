class Comment < ApplicationRecord
  TEASER_MAX_LENGTH = 256
  BODY_MAX_LENGTH = 2048
  MODEL_PREFIX = "cmt".freeze

  include AccountOwnable
  include UserOwnable

  has_many_attached :trix_attachments, dependent: :destroy
  before_validation :create_teaser
  after_commit :broadcast_event, on: :create

  AVAILABLE_ACTIONS = %i[
    activate
  ].freeze

  string_enum :status, %w[active archived], _default: :draft
  string_enum :notify_customer_with, %w[none mail sms], _default: :none
  belongs_to :commentable, polymorphic: true

  alias_attribute :author, :owner
  alias_attribute :author_id, :owner_id

  validates :body, presence: true, length: { maximum: BODY_MAX_LENGTH }
  validates :teaser, length: { maximum: TEASER_MAX_LENGTH }
  validate :account_assertions
  attribute :silent, :boolean, default: false

  def create_teaser
    return if body.blank?

    self.teaser = body[0..63] << "..."
  end

  def mini_teaser
    body[0..23] << "..."
  end

  def clean_mini_teaser
    ActionController::Base.helpers.strip_tags mini_teaser
  end

  private

  def account_assertions
    return if commentable.blank?

    errors.add(:commentable, "must be owned by the same account") unless commentable.account_id == account_id
    errors.add(:commentable, "owner have the same account") unless owner.account_id == account_id
  end

  def broadcast_event
    Event.broadcast(:comment_created, comment_id: id) unless silent
  end
end
