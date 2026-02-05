# frozen_string_literal: true

module Converter
  class ApiClient < BaseApiClient
    # def update_template(url:, uuid:)
    #   send_request(path: "/templates", body: { url:, name: uuid })
    # end

    # def delete_template(uuid:)
    #   send_request(path: "/templates", body: { name: uuid }, method: :delete)
    # end

    # "template_body": template data in plain text
    # "data": data to be used in template
    # "name": template name

    def convert(body:, footer:, data:, name:, debug: true)
      return Failure("Empty body") if body.blank?

      data = (data || {}).merge(locale: I18n.locale)

      body_params = { data:, name:, body: base64_encoded_body(body), debug: }
      body_params[:footer] = base64_encoded_body(footer) if footer.present?

      send_request(path: "/convert", body: body_params)
    end

    def parse(body:, data:, name:, debug: true)
      return Failure("Empty body") if body.blank?

      data = (data || {}).merge(locale: I18n.locale)

      send_request(path: "/parse", body: { data:, name:, body: base64_encoded_body(body), debug: })
    end

    private

    def base64_encoded_body(body)
      encoded_body = Base64.encode64(body)
      encoded_body.force_encoding(Encoding::BINARY)
    end

    def connection
      @connection ||= Faraday.new do |faraday|
        faraday.url_prefix = ENV.fetch('CONVERTER_URL')
        faraday.request :url_encoded
        faraday.adapter Faraday.default_adapter
        faraday.request  :json
        faraday.response :json, content_type: 'application/json'
      end
    end

    def headers
      {
        API_ACCESS_TOKEN: ENV.fetch('CONVERTER_TOKEN', nil),
        'Content-Type': 'application/json',
        Accept: 'application/json'
      }
    end

    class << self
      def update_template(url:, uuid:)
        new.update_template(url:, uuid:)
      end

      def delete_template(uuid:)
        new.delete_template(uuid:)
      end

      def convert(body:, footer:, data:, name:, debug: true)
        new.convert(body:, footer:, data:, name:, debug:)
      end

      def parse(body:, data:, name:, debug: true)
        new.parse(body:, data:, name:, debug:)
      end
    end
  end
end
