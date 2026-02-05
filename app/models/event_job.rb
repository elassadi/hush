class EventJob < ApplicationRecord
  string_enum :status, %w[unknown processing success failure], _default: :processing
  belongs_to :event

  def klass
    klass_name.constantize
  end

  delegate :name, to: :event, prefix: true, allow_nil: true
end
