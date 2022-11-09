# frozen_string_literal: true

require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }
require "trailblazer/test/deprecation/operation/assertions"

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end
RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = false
  config.include Request::JsonHelpers, type: :request
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.include FactoryBot::Syntax::Methods
  config.include AuthHelper
  config.include Requests::AuthHelpers::Includables, entity_type: :request
  config.extend Requests::AuthHelpers::Extensions, entity_type: :request
  config.include ParserHelper
  config.include VaultsHelper
  config.include UsersHelper
  config.include GroupsHelper
  config.include VaultItemsHelper
  include Trailblazer::Test::Assertions
  include Trailblazer::Test::Operation::Assertions
  include Trailblazer::Test::Deprecation::Operation::Assertions
  include Trailblazer::Test::Operation::PolicyAssertions
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
