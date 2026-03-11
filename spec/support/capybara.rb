require "capybara/rspec"
require "selenium/webdriver"
require "database_cleaner/active_record"

# Register Chrome driver first
def register_chrome_driver
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument("--headless") # Run in headless mode
  options.add_argument("--disable-blink-features=AutomationControlled")
  options.add_argument("--no-sandbox")
  options.add_argument("--disable-dev-shm-usage")
  options.add_argument("--disable-gpu")
  options.add_argument("--window-size=1920,1080")

  Capybara.register_driver :selenium_chrome do |app|
    Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
  end
end

register_chrome_driver

Capybara.configure do |config|
  config.default_driver = :selenium_chrome
  config.javascript_driver = :selenium_chrome
  config.default_max_wait_time = 10
  config.app_host = "http://localhost:3000"
end

# Configure DatabaseCleaner for feature tests
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
