module Avo
  class PatchedBaseResourceController < BaseResourceController
    rescue_from AvoAuthorizationClient::UnauthorizedError, with: :render_unauthorized

    def create # rubocop:todo Metrics/AbcSize
      # model gets instantiated and filled in the fill_model method
      saved = save_model
      @resource.hydrate(model: @model, view: :new, user: _current_user)

      # This means that the record has been created through another parent record and we need to attach it somehow.

      # TODO: we add saved to avoid creating a new record when the record is not saved
      if params[:via_resource_id].present? && saved
        @reflection = @model._reflections[params[:via_relation]]
        # Figure out what kind of association does the record have with the parent record

        # Fills in the required infor for belongs_to and has_many
        # Get the foreign key and set it to the id we received in the params
        if @reflection.is_a?(ActiveRecord::Reflection::BelongsToReflection) ||
           @reflection.is_a?(ActiveRecord::Reflection::HasManyReflection)
          related_resource = Avo::App.get_resource_by_model_name params[:via_relation_class]
          related_record = related_resource.find_record(params[:via_resource_id], params:)

          @model.send("#{@reflection.foreign_key}=", related_record.id)
          # only if saved
          @model.save
        end

        # For when working with has_one, has_one_through, has_many_through, has_and_belongs_to_many, polymorphic
        if @reflection.is_a? ActiveRecord::Reflection::ThroughReflection
          # find the record
          via_resource = ::Avo::App.get_resource_by_model_name(params[:via_relation_class]).dup
          @related_record = via_resource.find_record(params[:via_resource_id], params:)
          association_name = BaseResource.valid_association_name(@model, params[:via_relation])

          @model.send(association_name) << @related_record
        end
      end

      add_breadcrumb @resource.plural_name.humanize, resources_path(resource: @resource)
      add_breadcrumb t("avo.new").humanize
      set_actions

      if saved
        create_success_action
      else
        create_fail_action
      end
    end

    def save_model
      return super unless @view == :create || @view == :update

      result = save_model_transaction

      if result.success?
        @model = result.success
        return true
      end
      error_messages = if result.failure.is_a?(ActiveModel::Errors)
                         result.failure.full_messages
                       else
                         result.failure
                       end

      if result.failure.respond_to?(:errors)
        result.failure.errors.each do |error|
          @model.errors.add(error.attribute, error.message)
        end
      end

      @errors = Array.wrap([error_messages].flatten).compact if error_messages.present?

      nil
    end
  end
end
