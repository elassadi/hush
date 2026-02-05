class Notification < ApplicationRecord
  include ActionView::Helpers::DateHelper
  include AccountOwnable
  AVAILABLE_ACTIONS = %i[
    activate
  ].freeze

  store :metadata, accessors: %i[body action_link action_path action_params], coder: JSON
  string_enum :status, %w[new read deleted], _default: :new
  belongs_to :sender, class_name: "User"
  belongs_to :receiver, class_name: "User"
  has_many_attached :file_attachments, dependent: :destroy

  validates :title, presence: true

  before_validation :assign_sender
  before_validation :force_target_account

  after_commit :broadcast_events
  def sent_at
    return nil unless created_at

    distance_of_time_in_words_to_now(created_at)
  end

  def link
    return action_link if action_link

    nil
  end

  def path_with_params
    return { path: action_path, params: action_params } if action_path

    nil
  end

  private

  def assign_sender
    return if sender.present?

    self.sender = Current.user
  end

  def force_target_account
    return if receiver.blank?

    self.account = receiver.account
  end

  def broadcast_events
    return unless status_new?

    key = receiver.notifications_key

    broadcast_invoke_to(
      key, "classList.remove", args: ["hidden"], selector: "#notificationsIndicator"
    )
    # broadcast_invoke_to(key, "console.log", args: ["Repairset was saved! #{to_gid}"])
    # broadcast_invoke_later "window.location.reload", args: ["Repairset was saved! #{to_gid.to_s}"]

    # broadcast_invoke_later("reload", args: [""], selector: "#has_many_field_show_repair_set_entries")
    # broadcast_invoke_later "document.getElementById('has_many_field_show_repair_set_entries').reload",
    # args: ["Repairset was saved! #{to_gid.to_s}"]
    # broadcast_invoke "reload", selector: "#has_many_field_show_repair_set_entries",args:
    # ["Repairset was saved! #{to_gid.to_s}"]
    # .invoke("setAttribute", args: ["data-turbo-ready", true], selector: ".button") # selector

    # broadcast with a background job
    # broadcast_invoke_later "console.log", args: ["Post was saved! #{to_gid.to_s}"]
  end
end
