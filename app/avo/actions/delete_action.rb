class DeleteAction < ApplicationBaseAction
  self.name = t(:name)
  self.message = t(:message)
  self.icon = "heroicons/outline/trash"
  self.icon_class = "text-red-500"

  self.visible = lambda {
    next false unless view == :index || view == :show

    current_user.can?(:destroy, resource.model || resource.model_class)
  }

  def handle(**args)
    args[:models].each do |model|
      authorize_and_run(:destroy, model, &:destroy)
    end
  end
end
