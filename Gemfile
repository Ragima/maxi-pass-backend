# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.3.1'

gem 'bootsnap', '>= 1.1.0', require: false
gem 'jbuilder', '~> 2.8'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 3.11'
gem 'rack-cors', '~> 1.0', '>= 1.0.2'
gem 'rails', '~> 5.2.2'
# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'activerecord-import', '~> 1.0', '>= 1.0.2'
gem 'apitome', '~> 0.2.1'
gem 'bcrypt_pbkdf', '>= 1.0', '< 2.0'
gem 'capistrano', '~> 3.11'
gem 'capistrano-passenger', '~> 0.2.0'
gem 'capistrano-rails', '~> 1.4'
gem 'capistrano-rvm', '~> 0.1.2',     require: false
gem 'capistrano-sidekiq', '~> 1.0'
gem 'closure_tree', '~> 7.0'
gem 'devise_invitable', '~> 1.7.5'
gem 'devise_token_auth', '~> 0.2.0'
gem 'dotenv-rails', '~> 2.7.2'
gem 'ed25519', '>= 1.2', '< 2.0'
gem 'prawn', '~> 2.2', '>= 2.2.2'
gem 'prawn-table', '~> 0.2.2'
gem 'fast_jsonapi', '~> 1.5'
gem 'kaminari', '~> 1.1', '>= 1.1.1'
gem 'public_activity', '~> 1.6', '>= 1.6.3'
gem 'pundit', '~> 2.0', '>= 2.0.1'
gem 'sidekiq', '~> 5.0', '>= 5.0.5'
gem 'reform-rails', '~> 0.1.7'
gem 'rswag', '~> 2.0', '>= 2.0.5'
gem 'simple_endpoint', '~> 0.1.2'
gem 'trailblazer', '~> 2.1.0.rc1'
gem 'trailblazer-rails', '~> 2.1', '>= 2.1.7'
gem 'trailblazer-test', '~> 0.1.0'
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
gem 'paperclip', '~> 6.0.0'
gem 'devise-two-factor', '~> 3.0', '>= 3.0.3'
gem 'rqrcode', '~> 0.10.1'
gem 'devise-security', '~> 0.14.3'
gem 'sentry-raven', '~> 2.12', '>= 2.12.3'

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'dotenv-rails', '~> 2.7.2'
  gem 'factory_bot_rails', '~> 5.0', '>= 5.0.1'
  gem 'ffaker', '~> 2.10'
  gem 'rspec-rails', '~> 3.8', '>= 3.8.2'
  gem 'rspec_api_documentation', '~> 6.1'
  gem 'rubocop', '~> 0.65.0', require: true
  gem 'rubocop-rspec', '~> 1.32'
end

group :tests do
  gem 'database_cleaner', '~> 1.7'
  gem 'pundit-matchers', '~> 1.6.0'
  gem 'shoulda-matchers', '~> 4.0', '>= 4.0.1'
  gem 'simplecov', '~> 0.16.1'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end
