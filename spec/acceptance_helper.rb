# frozen_string_literal: true

require 'rails_helper'
require 'rspec_api_documentation'
require 'rspec_api_documentation/dsl'
require 'support/parser_helper'
require 'support/auth_helper'

RspecApiDocumentation.configure do |config|
  config.format = [:json]
  config.curl_host = 'http://localhost:3000/'
  config.api_name = 'MaxiPass V2 API'
end
