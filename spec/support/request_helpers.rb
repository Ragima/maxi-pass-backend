# frozen_string_literal: true

module Request
  module JsonHelpers
    def json
      JSON.parse(response.body)
    end

    def json_error
      json['errors']
    end
  end
end
