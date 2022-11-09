# frozen_string_literal: true

DeviseTokenAuth.setup do |config|
  config.default_confirm_success_url = Rails.application.credentials.dig(:devise, :default_confirm_success_url)
  config.default_password_reset_url = Rails.application.credentials.dig(:devise, :default_password_reset_url)
  # config.default_password_reset_url = ENV['PASSWORD_RESET_URL']
  # config.default_confirm_success_url = ENV['CONFIRM_SUCCESS_URL']
  config.change_headers_on_each_request = false

  config.token_lifespan = 30.minutes

  config.max_number_of_devices = 10

  config.headers_names = { 'access-token': 'access-token',
                           'client': 'client',
                           'expiry': 'expiry',
                           'uid': 'uid',
                           'token-type': 'token-type' }

end
