module UserOwnable
  extend ActiveSupport::Concern

  included do
    belongs_to :owner, class_name: "User"
    before_validation :assign_user_as_owner
  end

  def assign_user_as_owner
    return unless respond_to?(:owner_id)
    return if owner_id.present?
    return if Current.user.blank?

    self.owner_id = Current.user.id
    # TODO: polymorphic association
    # self.owner_type = User
  end
end
