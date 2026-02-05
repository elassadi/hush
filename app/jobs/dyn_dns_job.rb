# frozen_string_literal: true

class DynDnsJob < ApplicationJob
  def perform(ip_address:)
    update_dns_record(ip_address)
  end

  private

  def update_dns_record(ip_address)
    response = send_dns_update(ip_address)

    if response.success?
      render_success_response(response)
    else
      render_error_response(response)
    end
  rescue StandardError => e
    render_internal_error(e)
  end

  def api_url
    "https://api.cloudflare.com/client/v4/zones/#{ENV.fetch('SMS_SERVER_ZONE_ID',
                                                            nil)}/dns_records/#{ENV.fetch('SMS_SERVER_RECORD_ID', nil)}"
  end

  def faraday_connection
    Faraday.new(url: api_url) do |f|
      f.request :json
      f.response :logger
      f.adapter Faraday.default_adapter
    end
  end

  def send_dns_update(ip_address)
    faraday_connection.put do |req|
      req.headers['Authorization'] = "Bearer #{ENV.fetch('CLOUDFLARE_API_TOKEN', nil)}"
      req.headers['Content-Type'] = 'application/json'
      req.body = dns_update_payload(ip_address).to_json
    end
  end

  def dns_update_payload(ip_address)
    {
      type: "A",
      name: ENV.fetch('SMS_SERVER_RECORD_NAME', nil),
      content: ip_address,
      ttl: 1,
      proxied: false
    }
  end

  def render_success_response(response)
    # render json: { status: 'success', response: JSON.parse(response.body) }, status: :ok
    CoreLogger.info("DNS record updated successfully #{response.body}")
  end

  def render_error_response(response)
    # render json: { status: 'error', response: JSON.parse(response.body) }, status: response.status
    CoreLogger.error("Failed to update DNS record #{response.body}")
  end

  def render_internal_error(exception)
    # render json: { status: 'error', message: exception.message }, status: :internal_server_error
    CoreLogger.error("Internal error: #{exception.message}")
  end
end
