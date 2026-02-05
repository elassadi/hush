class Sequence < ApplicationRecord
  include AccountOwnable

  string_enum :sequenceable_type, %w[customer issue invoice_document kva_document order_document], _default: :active

  store :metadata, accessors: %i[], coder: JSON

  belongs_to :setting

  validates :sequenceable_type, presence: true

  validate :counter_start_is_valid

  validates :counter_start, format: { with: /\A\d*\Z/ }

  def sequenceable_class
    sequenceable_type.classify.constantize
  end

  def next_sequence_id
    [current_sequence_id&.to_i || 0, counter_start].max + 1
  end

  def current_sequence_id
    sequenceable_class.where(account_id:).order(created_at: :desc).first&.sequence_id
  end

  private

  def counter_start_is_valid
    return if counter_start >= current_sequence_id.to_i

    errors.add(:counter_start, :greater_than_last_sequence_id, current_sequence_id:)

    # errors.add(:counter_start, "must be greater than or equal to the last sequence_id (#{current_sequence_id})")
  end

  class << self
    def next_sequence_id(account_id:, sequenceable:)
      active_sequence = where(account_id:, sequenceable_type: sequenceable.class.name.underscore)
                        .where(active_since: Time.zone.today..).order(active_since: :desc).first
      return active_sequence.next_sequence_id if active_sequence

      (sequenceable.class.where(account_id:).order(created_at: :desc).first&.sequence_id.to_i || 0) + 1
    end
  end
end
