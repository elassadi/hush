module Avo
  class BaseResourceController < ResourcesController
    # rescue_from ActiveRecord::RecordNotFound, with: :redirect_to_error_page

    def redirect_to_error_page(exception)
      # Redirect the user to /error_page

      # Extract the model name from the exception if available
      model_name = exception.model

      # Set the instance variable to pass to the 404 view
      @model_name = model_name ? model_name.constantize.model_name.human : nil
      redirect_to '/error_page', alert: "Das angeforderte Objekt #{@model_name} konnte nicht gefunden werden."
    end

    def render_unauthorized
      flash[:error] = t "avo.not_authorized"

      redirect_url = if request.referer.blank? || (request.referer == request.url)
                       root_url
                     else
                       request.referer
                     end

      redirect_to(redirect_url)
    end

    private

    def check_completed_onboarding
      return if Current.user.account.completed_onboarding?
      return if instance_of?(Avo::MerchantsController)
      return if instance_of?(Avo::NotificationsController)
      return unless request.format.html?

      redirect_to resources_merchant_path(Current.user.account.merchant)
    end
  end
end
