 # frozen_string_literal: true

 module Telegram
  class Sender < BaseService
    attributes :text
    optional_attributes :parse_mode

    BASE_URL = "https://api.telegram.org/bot%s"

    def call
      return test_connection if text =="test"
      return Failure("Text can't be blank") if text.blank?

      response = send_message

      if response.code == "200"
        Rails.logger.info("Telegram message sent successfully") if defined?(Rails)
        Success(true)
      else
        log_error("Failed to send Telegram message: #{response.code} - #{response.body}")
        Failure("Telegram request failed with status #{response.code}")
      end
    rescue StandardError => e
      log_error("Failed to send Telegram message: #{e.message}")
      Failure(e.message)
    end

private

    def test_connection
      require "net/http"
      require "json"
      require "uri"

      uri = URI("#{base_url}/getMe")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 10

      request = Net::HTTP::Get.new(uri)
      response = http.request(request)

      if response.code == "200"
        bot_info = JSON.parse(response.body)
        username = bot_info.dig("result", "username")
        Rails.logger.info("Telegram bot connected: @#{username}") if defined?(Rails)
        Success(true)
      else
        log_error("Telegram connection test failed: #{response.code} - #{response.body}")
        Failure("Telegram connection test failed with status #{response.code}")
      end
    rescue StandardError => e
      log_error("Telegram connection test failed: #{e.message}")
      Failure(e.message)
    end


    def send_message
      require "net/http"
      require "json"
      require "uri"

      uri = URI("#{base_url}/sendMessage")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 30

      request = Net::HTTP::Post.new(uri)
      request["Content-Type"] = "application/json"
      request.body = payload.to_json

      http.request(request)
    end

    def payload
      data = {
        chat_id: chat_id,
        text:
      }
      data[:parse_mode] = parse_mode || "HTML"
      data
    end

    def bot_token
      ENV.fetch("TELEGRAM_BOT_TOKEN_INSTAGRAM") do
        raise ArgumentError, "TELEGRAM_BOT_TOKEN_INSTAGRAM environment variable is required"
      end
    end

    def chat_id
      ENV.fetch("TELEGRAM_CHAT_ID_INSTAGRAM") do
        raise ArgumentError, "TELEGRAM_CHAT_ID_INSTAGRAM environment variable is required"
      end
    end

    def base_url
      format(BASE_URL, bot_token)
    end

    def log_error(message)
      Rails.logger.error(message) if defined?(Rails)
    end
  end
 end

