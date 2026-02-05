# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  extend WithStringEnum
  before_save :touch_status_timestamps
  before_create :generate_uuid
  before_create :assign_sequence_id
  primary_abstract_class

  self.abstract_class = true

  # before_create :restrict_by_plan
  validate :restrict_by_plan

  scope :by_account, lambda {
    next where("1") if Current.user.access_level_global?

    ids = [Current.user.current_account.id]

    ids << Account.recloud.id if Constants::SHARED_DATA_MODELS.include?(model)

    where(account_id: ids)
  }

  def data_access_policy_class
    self.class.data_access_policy_class
  end

  def status_at(status_field_name = "status")
    map = {
      "active" => "activated"
    }

    status_value = send(status_field_name)
    status_value = map[status_value] || status_value
    Rails.logger.debug { " Getting #{status_value}_at " }
    self["#{status_value}_at"]
  end

  def touch_status_timestamps(status_field_name = "status")
    return unless self.class.column_names.include? status_field_name

    return unless send("#{status_field_name}_changed?")

    map = {
      "active" => "activated"
    }
    status_value = send(status_field_name)
    status_value = map[status_value] || status_value

    return unless has_attribute?("#{status_value}_at")

    self["#{status_value}_at"] = Time.zone.now
  end

  # def can_be?(action)
  #   can_be_method = "can_be_#{action}d?"
  #   can_method = "can_#{action}?"

  #   if respond_to?(can_be_method)
  #     send(can_be_method)
  #   elsif respond_to?(can_method)
  #     send(can_method)
  #   elsif respond_to?("#{action}?")
  #     send("#{action}?")
  #   else
  #     false
  #   end
  # end

  def can_be?(action)
    method_name = detect_method_name(action)

    return send(method_name) if method_name

    false
  end

  # rubocop:disable Rails/ActiveRecordOverride
  def destroy
    soft_delete! || super
  end
  # rubocop:enable Rails/ActiveRecordOverride

  def template_attributes
    {}
  end

  private

  def detect_method_name(action)
    ["can_be_#{action}d?", "can_be_#{action}ed?", "can_#{action}?", "#{action}?"].detect do |method|
      respond_to?(method)
    end
  end

  def restrict_by_plan
    return if Rails.env.test?

    return unless Current.user
    return if Current.user.account.recloud?

    result = PlanRestrictionPolicy.call(resource_class: self.class, account: Current.user.account)
    return if result.success?

    errors.add(:base, I18n.t(:plan_limits_exhausted, scope: "errors.messages"))

    # throw :abort
  end

  def model_prefix
    (defined?(self.class::MODEL_PREFIX) && self.class::MODEL_PREFIX) || self.class.name.downcase[0..2]
  end

  def generate_uuid
    return unless self.class.column_names.include? 'uuid'
    return if uuid.present?

    loop do
      self.uuid = "#{model_prefix}_" << SecureRandom.uuid.delete('-')[0..7]
      break unless self.class.exists?(uuid:)
    end
  end

  def assign_sequence_id
    return unless self.class.column_names.include? 'sequence_id'
    return if sequence_id.present?

    self.sequence_id ||= Sequence.next_sequence_id(account_id:, sequenceable: self)
  end

  def soft_delete!
    return unless can_be_soft_deleted?

    status_deleted!
  end

  def can_be_soft_deleted?
    self.class.column_names.include?('status') &&
      self.class.column_names.include?('deleted_at')
  end

  class << self
    def random
      offset(rand(count)).first
    end

    def data_access_policy_class
      "#{self}DataAccessPolicy".constantize
    rescue NameError
      GlobalDataAccessPolicy
    end

    def human_enum_names(enum_name, reject: nil, translate: true)
      enum_values = send(enum_name.to_s.pluralize).keys
      enum_values.reject! { |key| Array(reject).map(&:to_s).include?(key) }

      enum_values.index_with do |enum_value|
        translate ? human_enum_name(enum_name, enum_value) : enum_value
      end
    end

    def human_enum_name(enum_name, enum_value)
      translation_key = "activerecord.attributes.#{model_name.i18n_key}.#{enum_name.to_s.pluralize}.#{enum_value}"

      return I18n.t(translation_key) if I18n.exists?(translation_key)

      I18n.t(enum_value, scope: [:shared, enum_name])
    end
  end
end

# def soft_delete!
#   return unless can_be_soft_deleted?
#   status_deleted!
# end

# def can_be_soft_deleted?
#   self.class.column_names.include?('status') &&
#     self.class.column_names.include?('deleted_at')
# end

# def destroy
#   soft_delete! || super
# end
