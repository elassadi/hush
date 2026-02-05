module AvoPatches
  module ActionsController
    extend ActiveSupport::Concern

    def action_class
      klass_name = params[:action_id].gsub("avo_actions_", "").camelize
      resource_klass = params[:resource_name].camelize

      ::ApplicationBaseAction.descendants.find do |action|
        [klass_name, "#{resource_klass}::#{klass_name}"].include?(action.to_s)
      end
    end
  end
end
