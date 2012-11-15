# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # Filter examples to run those that have focus: true
  # or run all of the examples if none have focus
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true 

  def test_sign_in(user)
    controller.sign_in(user)
  end

  def integration_test_sign_in(user)   
    post signin_path, :name => user.user_name, :password => user.password
    user.save(:validate => false)
    user
  end

  def request_sign_in(user)
    visit signin_path
    fill_in "User name", :with => user.user_name
    fill_in "Password", :with  => user.password
    click_button "Sign In"
    user
  end

  def request_send_message(message)
    fill_in "message_content", :with => message
    click_button "Send"
  end
 
  def within_browser(name)
    Capybara.session_name = name

    yield
  end 

  # Configuration for databse cleaner
  config.before(:each) do
    DatabaseCleaner.strategy = :truncation
  end
  
  config.before(:each) do
    DatabaseCleaner.start
  end
  
  config.after(:each) do
    DatabaseCleaner.clean
  end
end

