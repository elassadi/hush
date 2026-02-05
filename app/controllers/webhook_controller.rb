# frozen_string_literal: true

class WebhookController < ApplicationController
  protect_from_forgery with: :null_session
  DYNDNS_TOKEN = "MeAndMyFrieds"

  def dyndns
    return render html: "Unauthorized", status: :unauthorized unless params[:token] == DYNDNS_TOKEN

    ip_address = params[:ip]

    unless ip_address&.match?(IPAddr::RE_IPV4ADDRLIKE)
      return render json: { error: "IP address not provided" }, status: :bad_request
    end

    DynDnsJob.perform_later(ip_address:)
    render json: { ok: true }, status: :ok
  end

  def sms
    webhook_request = save_webhook_request(klass: SmsWebhookRequest)
    WebhookJob.perform_later(webhook_request.id)
    render json: { ok: true }, status: :ok
  end

  def paypal
    webhook_request = save_webhook_request(klass: PaypalWebhookRequest)
    WebhookJob.perform_later(webhook_request.id)
    render json: { ok: true }, status: :ok
  end

  def stripe
    webhook_request = save_webhook_request(klass: StripeWebhookRequest)

    WebhookJob.perform_later(webhook_request.id) if webhook_request.verified?(request.body.read)

    render json: { ok: true }, status: :ok
  # Invalid signature
  rescue Stripe::SignatureVerificationError => e
    webhook_request.update(status: :forbiden)
    render json: { error: e.inspect }, status: :bad_request
  end

  private

  def save_webhook_request(klass:)
    klass.create!(
      body:,
      path: request.path,
      headers: http_headers,
      status: :pending
    )
  end

  def body
    JSON.parse(request.body.read)
  rescue JSON::ParserError
    request.body.read
  end

  def http_headers
    hsh = request.headers.to_h
    hsh.slice(*hsh.keys.select { |k| k.start_with?("HTTP") })
  end
end
