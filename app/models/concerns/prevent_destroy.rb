module PreventDestroy
  extend ActiveSupport::Concern

  included do |base|
    before_destroy { |record| record.check_associations(base.prevent_destroy_associations) }
  end

  def check_associations(associations)
    return if Current.user.admin? && !Rails.env.production?

    associations.each do |association|
      if self.class.reflect_on_association(association).klass.exists?(account_id: id)
        errors.add(:base, "Cannot destroy account while #{association} exist")
        throw(:abort)
      end
    end
  end

  class_methods do
    def prevent_destroy(*associations)
      @prevent_destroy_associations = associations
    end

    def prevent_destroy_associations
      @prevent_destroy_associations || []
    end
  end
end
