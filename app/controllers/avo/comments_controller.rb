# This controller has been generated to enable Rails' resource routes.
# You shouldn't need to modify it in order to use Avo.

module Avo
  class CommentsController < BaseResourceController
    def new
      super

      # TODO: create a PR for Avo to merge those changes
      # polymorphic with STI classes
      # model.(polymorphic association get by default the base/parent class assigned we need the child Class
      reflection = @model._reflections[params[:via_relation]]
      return unless reflection.foreign_type && @model.respond_to?(reflection.foreign_type)

      @model.send("#{reflection.foreign_type}=", params[:via_relation_class])
    end

    private

    def save_model
      return super unless @view == :create

      parent_resource = ::Avo::App.get_resource_by_model_name(params[:via_relation_class])
      reflection = @model._reflections[params[:via_relation]]
      if parent_resource&.model_class&.base_class
        @model.send("#{reflection.foreign_type}=", parent_resource.model_class.base_class)
      end

      super
    end
  end
end
