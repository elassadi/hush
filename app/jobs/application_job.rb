# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  RUN_NOW = false
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError

  discard_on ActiveJob::DeserializationError do |_job, error|
    Rails.logger.error("Skipping job ActiveJob::DeserializationError (#{error.message})")
  end

  self.log_arguments = false

  around_perform do |_job, block|
    ::PaperTrail.request.whodunnit = User.system_user
    ::PaperTrail.request.controller_info = { whodunnit_type: "User" }
    block.call
  end
end
