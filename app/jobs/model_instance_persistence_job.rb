# frozen_string_literal: true

class ModelInstancePersistenceJob < ApplicationJob
  def perform(model_class, params)
    model_class.to_s.constantize.new(params.except(:id, "id")).save!
  end
end
