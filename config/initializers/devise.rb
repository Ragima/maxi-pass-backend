# frozen_string_literal: true

Devise.setup do |config|
  config.warden do |manager|
    manager.default_strategies(:scope => :user).unshift :two_factor_authenticatable
  end

  config.reconfirmable = false
  config.invite_for = 5.days
  config.secret_key = Rails.application.secrets.secret_key_base
  config.mailer_sender = 'maxipass.mailer@bookstime.com'
  config.reset_password_within = 6.hours
  config.sign_in_after_reset_password = true
  config.authentication_keys = %i[email team_name otp_attempt]
  config.invite_key = { email: Devise.email_regexp, team_name: Team::NAME_REGEX }
  config.lock_strategy = :failed_attempts
  config.unlock_keys = %i[email team_name otp_attempt]
  config.unlock_strategy = :both
  config.maximum_attempts = 5
  config.unlock_in = 1.hour
  config.last_attempt_warning = true
  config.mailer = "DeviseCustomMailer"
end
