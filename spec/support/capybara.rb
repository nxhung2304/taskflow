require "capybara/rspec"
require "selenium/webdriver"

Capybara.configure do |config|
  config.default_driver = :selenium_chrome
  config.javascript_driver = :selenium_chrome
  config.default_max_wait_time = 10
  config.app_host = "http://localhost:3000"

  # Configure Selenium with Chrome options
  register_chrome_driver
end

def register_chrome_driver
  options = Selenium::WebDriver::Chrome::Options.new
  # options.add_argument("--headless") # Uncomment for headless mode
  options.add_argument("--disable-blink-features=AutomationControlled")
  options.add_argument("--start-maximized")
  options.add_argument("--disable-extensions")
  options.add_argument("--disable-popup-blocking")

  # Add logging if needed
  options.add_argument("--enable-logging")
  options.add_argument("--v=1")

  Capybara.register_driver :selenium_chrome do |app|
    Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
  end
end

# Configure DatabaseCleaner for feature tests
require "database_cleaner/active_record"

DatabaseCleaner.allow_remote_database_url = true

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each, type: :feature) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
  end

  config.after(:each, type: :feature) do
    DatabaseCleaner.clean
  end
end
