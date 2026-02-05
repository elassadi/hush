module Requests
  module JsonHelpers
    def json_body
      JSON.parse(response.body).with_indifferent_access if response.body
    end
  end
end
