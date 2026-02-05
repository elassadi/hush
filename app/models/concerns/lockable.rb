# app/models/concerns/lockable.rb
module Lockable
  extend ActiveSupport::Concern
  DEFAULT_LOCK_EXPIRE_AFTER = 15.minutes

  included do
    store :lockdata, accessors: %i[locked_at unlocked_at unlocked_by_user_id locked_by_user_id
                                   lock_history lock_option], coder: JSON
    after_initialize :initialize_lock_history, if: :new_record?

    scope :locked, lambda {
      where(" JSON_UNQUOTE(JSON_EXTRACT(JSON_UNQUOTE(lockdata), '$.locked_at')) IS NOT NULL")
        .where(" JSON_UNQUOTE(JSON_EXTRACT(JSON_UNQUOTE(lockdata), '$.unlocked_at')) IS NULL  ")
    }
  end

  def locked
    locked_at.present? && unlocked_at.blank?
  end
  alias_method :locked?, :locked

  def apply_lock!(lock_option: :temporary)
    lock_and_save_event!(lock_option:)
  end

  def unlock!
    self.unlocked_at = Time.zone.now
    self.unlocked_by_user_id = Current.user.id
    save!
  end

  private

  def lock_and_save_event!(lock_option:)
    self.locked_at = Time.zone.now
    self.locked_by_user_id = Current.user.id
    lockdata.delete("unlocked_at")
    self.lock_option = lock_option
    save!
  end

  def initialize_lock_history
    self.lock_history ||= []
  end
end
