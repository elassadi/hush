# frozen_string_literal: true

class Document < ApplicationRecord
  include AccountOwnable

  string_enum :status, %w[active archived deleted], _default: :active
  has_one_attached :file

  validates :status, inclusion: { in: statuses }
  validates :file, presence: true
  belongs_to :documentable, polymorphic: true, inverse_of: :documents, optional: true
  attribute :active_record, default: 1

  validates :documentable_id, uniqueness: { scope: %i[account_id documentable_type type key active_record] }

  before_validation :before_validation
  before_save :touch_status_timestamps, if: :will_save_change_to_status?
  before_create :assign_key

  def download_url
    ActiveStorage::Current.url_options = Rails.application.config.default_url_options
    file.url
  end

  def template_attributes
    {
      id:,
      uuid:,
      sequence_id:,
      key:,
      file_name:,
      created_at:
    }
  end

  def prefix
    (defined?(self.class::DOCUMENT_PREFIX) && self.class::DOCUMENT_PREFIX) || self.class.name.downcase[0..2]
  end

  def title
    "#{prefix}-#{sequence_id}"
  end

  private

  def file_name
    return "No File" unless file.blob

    # rubocop:disable Rails/OutputSafety
    path = Rails.application.routes.url_helpers.rails_blob_path(file, only_path: true)
    %{<a target="_blank" href="#{path}">#{file.filename}</a>}.html_safe
    # rubocop:enable Rails/OutputSafety
  end

  def before_validation
    self.documentable = Account.recloud if documentable.blank?
  end

  def assign_key
    self.counter = (last_document&.counter || 0) + 1 unless counter > 0
    self.key ||= "#{prefix}-#{counter}"
  end

  def last_document
    Document.where(account:, type:).order(created_at: :desc).first
  end

  class << self
    def init(status:, documentable:, account_id:)
      instance = new(status:, documentable:, account_id:)
      instance.send(:generate_uuid)
      instance.send(:assign_key)
      instance.send(:assign_sequence_id)
      instance.created_at = Time.zone.now
      instance.updated_at = Time.zone.now
      instance
    end
  end
end
