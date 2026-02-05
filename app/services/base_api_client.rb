# frozen_string_literal: true

class BaseApiClient < RecloudCore::DryBase
  private

  def send_request(path:, body: nil, method: :post)
    result = connection.run_request(method, path.to_s, nil, nil) do |request|
      request.headers = (request.headers || {}).merge(headers)
      request.body = body
    end
    unless result.success?
      ErrorTracking.capture_message(
        "could not execute api call to converter application " \
        "url: #{result.env.url}" \
        "status: #{result.status} #{result.body}" \
        "error: #{result.body}"
      )
    end
    Success(result)
  end
end
