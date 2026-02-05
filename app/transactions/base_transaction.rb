class BaseTransaction < RecloudCore::DryBase
  def capture_transaction_exception(exception)
    failure_message, track_error = extract_failure_message(exception.result.failure)
    return unless track_error

    ErrorTracking.capture_message(
      "#{self.class.name} for device failed with #{failure_message}"
    )
  end

  private

  def extract_failure_message(failure)
    if failure.is_a?(String)
      [failure, true]
    elsif failure.respond_to?(:errors) && failure.errors.any? && failure.errors.respond_to?(:full_messages)
      [failure.errors.full_messages.join(", "), false]
    else
      [failure.inspect, true]
    end
  end
end
