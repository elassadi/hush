# frozen_string_literal: true

class ConverterRequestJob < ApplicationJob
  def perform(method:, **args)
    Converter::ApiClient.send(method, **args)
  end
end
