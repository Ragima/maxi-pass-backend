# frozen_string_literal: true

require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'action_cable/engine'
require 'sprockets/railtie'
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
Dotenv::Railtie.load
HOSTNAME = ENV['HOSTNAME']

module MaxipassV2
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2
    config.active_job.queue_adapter = :sidekiq

    config.middleware.use Rack::Cors do
      allow do
        origins '*'
        resource '*',
                 headers: :any,
                 expose: %w[access-token expiry token-type uid client master-key],
                 methods: %i[get post options delete put]
      end
    end
    config.api_only = true
    config.before_eager_load do
      I18n.locale = :en
      I18n.load_path += Dir[Rails.root.join('config', 'locales', 'en.yml').to_s]
      I18n.reload!
    end
  end
end

unless Rails.env.production?
  RSpec.configure do |config|
    config.swagger_dry_run = false
  end
end
