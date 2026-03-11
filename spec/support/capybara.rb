require "capybara/rspec"
require "selenium/webdriver"

Capybara.configure do |config|
  config.test_app = ->(rack_app) { rack_app }
  config.default_driver = :selenium_chrome
  config.javascript_driver = :selenium_chrome
  config.default_max_wait_time = 10

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

# Configure RSpec for feature tests
RSpec.configure do |config|
  config.before(:each, type: :feature) do
    # Ensure database is clean
    DatabaseCleaner.start
  end

  config.after(:each, type: :feature) do
    DatabaseCleaner.clean
  end
end
