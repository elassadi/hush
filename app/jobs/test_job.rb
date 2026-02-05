# frozen_string_literal: true

class TestJob < ApplicationJob
  def perform(**args)
    Chatbot::RunnerService.call(**args)
  end
end
