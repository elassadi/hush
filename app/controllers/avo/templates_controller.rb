# This controller has been generated to enable Rails' resource routes.
# You shouldn't need to modify it in order to use Avo.
module Avo
  class TemplatesController < BaseResourceController
    # def new

    #   @model = @resource.model_class.new
    #   @resource = @resource.hydrate(model: @model, view: :new, user: _current_user)

    #   set_actions

    #   @page_title = @resource.default_panel_name.to_s

    #   #PATCH-TODO
    #   if (params[:via_cloned_id])
    #     via_cloned_model = @resource.class.find_scope.find params[:via_cloned_id]
    #     @resource.hydrate model: via_cloned_model
    #   end
    #   if is_associated_record?
    #     via_resource = Avo::App.get_resource_by_model_name(params[:via_relation_class]).dup
    #     via_model = via_resource.find_record params[:via_resource_id], params: params
    #     via_resource.hydrate model: via_model

    #     add_breadcrumb via_resource.plural_name, resources_path(resource: via_resource)
    #     add_breadcrumb via_resource.model_title, resource_path(model: via_model, resource: via_resource)
    #   end

    #   add_breadcrumb @resource.plural_name.humanize, resources_path(resource: @resource)
    #   add_breadcrumb t("avo.new").humanize

    #   respond_to do |format|
    #     format.html { render params[:modal_resource] ? :new_modal : :new}
    #   end
    # end

    # def create
    #   # model gets instantiated and filled in the fill_model method
    #   saved = save_model
    #   @resource.hydrate(model: @model, view: :new, user: _current_user)

    #   # This means that the record has been created through another parent record and we need to attach it somehow.
    #   if params[:via_resource_id].present?
    #     @reflection = @model._reflections[params[:via_relation]]
    #     # Figure out what kind of association does the record have with the parent record

    #     # Fills in the required infor for belongs_to and has_many
    #     # Get the foreign key and set it to the id we received in the params
    #     if @reflection.is_a?(ActiveRecord::Reflection::BelongsToReflection) ||
    # @reflection.is_a?(ActiveRecord::Reflection::HasManyReflection)
    #       related_resource = Avo::App.get_resource_by_model_name params[:via_relation_class]
    #       related_record = related_resource.find_record params[:via_resource_id], params: params

    #       @model.send("#{@reflection.foreign_key}=", related_record.id)
    #       @model.save
    #     end

    #     # For when working with has_one, has_one_through, has_many_through, has_and_belongs_to_many, polymorphic
    #     if @reflection.is_a? ActiveRecord::Reflection::ThroughReflection
    #       # find the record
    #       via_resource = ::Avo::App.get_resource_by_model_name(params[:via_relation_class]).dup
    #       @related_record = via_resource.find_record params[:via_resource_id], params: params
    #       association_name = BaseResource.valid_association_name(@model, params[:via_relation])

    #       @model.send(association_name) << @related_record
    #     end
    #   end

    #   add_breadcrumb @resource.plural_name.humanize, resources_path(resource: @resource)
    #   add_breadcrumb t("avo.new").humanize
    #   set_actions

    #   if saved
    #     create_success_action
    #   else
    #     create_fail_action
    #   end
    # end

    def save_model
      @model.name = params[:template][:name] if @model.name.blank? && params[:template][:name].present?
      super
    end

    def show
      super
      respond_to do |format|
        format.json { render json: @model }
        format.html
      end
    end
  end
end
