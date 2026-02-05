# This controller has been generated to enable Rails' resource routes.
# You shouldn't need to modify it in order to use Avo.

module Avo
  class NotificationsController < BaseResourceController
    def show
      @model.status_read! if @model.status_new? && (@model.receiver == Current.user)

      return redirect_to @model.link if @model.link.present?

      if @model.path_with_params
        return redirect_to avo.send(@model.path_with_params[:path], @model.path_with_params[:params])
      end

      super
    end

    def preview
      @notifications = Current.user.top10_notifications
    end
  end
end
