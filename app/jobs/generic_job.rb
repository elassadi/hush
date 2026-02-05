# frozen_string_literal: true

class GenericJob < ApplicationJob
  def perform(args)
    klass = args[:klass]
    params = args[:params] || {}
    current_user_id = params[:current_user_id]
    Current.user = User.find(current_user_id) if current_user_id
    klass.to_s.constantize.call(**params)
  end
end
