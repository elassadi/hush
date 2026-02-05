class CloneAction < ApplicationBaseAction
  self.name = "Clone"
  self.no_confirmation = true
  self.icon = "heroicons/outline/document-duplicate"

  self.visible = -> { (view == :show) && current_user.can?(:create, resource.model_class) }

  def handle(**args)
    model = args[:models].first

    return warn I18n.t('helpers.account.feature_not_available') if Current.account.feature_not_available?(:cloning)

    clone(model, args[:resource])
  end

  def clone(model, resource)
    current_user.authorize!(:create, model)
    redirect_to avo.send :"new_resources_#{resource.singular_route_key}_path", { via_cloned_id: model.id }
  rescue CanCan::AccessDenied
    fail I18n.t('shared.messages.no_access')
  end
end
