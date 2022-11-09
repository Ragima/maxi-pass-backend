# frozen_string_literal: true

IGNORE_DEFAULT = %w[AbstractController::ActionNotFound ActionController::RoutingError ActionController::UnknownAction CGI::Session::CookieStore::TamperedWithCookie Mongoid::Errors::DocumentNotFound Sinatra::NotFound ActiveJob::DeserializationError].freeze

Raven.configure do |config|
  config.dsn = 'https://5d9fec51128d432a9796c309d75ef7f5:0e125585956b4ed3adf6b74e1a95ad7c@sentry.io/1852698'
  config.environments = %w[production]
  config.tags = { environment: Rails.env }
  config.excluded_exceptions = IGNORE_DEFAULT.dup
  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
end