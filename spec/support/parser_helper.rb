# frozen_string_literal: true

module ParserHelper
  def body
    JSON.parse(response_body)
  end

  def response_body
    JSON.parse(response.body)
  end
end
