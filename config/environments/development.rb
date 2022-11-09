# frozen_string_literal: true

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
        'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options)
  config.active_storage.service = :local

  # Don't care if the mailer can't send.
  # config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  #  Ensure you have defined default url options in your environments files. Here
  #      is an example of default_url_options appropriate for a development environment

  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

  config.debug_exception_response_format = :api

  config.action_mailer.raise_delivery_errors = true
  config.active_job.queue_adapter = :sidekiq

  config.action_mailer.perform_deliveries = true

  config.action_mailer.delivery_method = :test

  # config.action_mailer.smtp_settings = {
  #     address: 'smtp.sendgrid.net',
  #     port: 587,
  #     domain: Rails.application.credentials.dig(:smtp, :domain),
  #     user_name: Rails.application.credentials.dig(:smtp, :user_name),
  #     password: Rails.application.credentials.dig(:smtp, :password),
  #     authentication: :plain,
  #     openssl_verify_mode: 'none'
  # }
end
