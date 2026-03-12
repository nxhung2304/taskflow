# End-to-End Tests with Selenium Chrome

This directory contains automated end-to-end (E2E) tests using Capybara and Selenium WebDriver that open an actual Chrome browser to test the application.

## Prerequisites

1. **Chrome Browser** - Must be installed on your system
2. **ChromeDriver** - Automatically managed by `webdrivers` gem, or install manually
3. **Bundle Dependencies** - Run `bundle install`

## Installation

1. Install gems:
```bash
bundle install
```

2. Optional: Install ChromeDriver manually (if auto-download doesn't work)
```bash
# macOS
brew install chromedriver

# Or download from: https://chromedriver.chromium.org/
```

## Running Tests

### Run All Feature Tests
```bash
bundle exec rspec spec/features/ --format documentation
```

### Run Specific Test File
```bash
bundle exec rspec spec/features/admin/tasks_crud_spec.rb
```

### Run Single Test Scenario
```bash
bundle exec rspec spec/features/admin/tasks_crud_spec.rb -e "Admin can create a new task"
```

### Run in Headless Mode (no visible browser)
Edit `spec/support/capybara.rb` and uncomment:
```ruby
options.add_argument("--headless")
```

## Test Coverage

The Tasks CRUD feature tests include:

### Dashboard & Navigation
- ✅ View tasks from dashboard quick-access card
- ✅ Navigate to tasks from sidebar menu
- ✅ View tasks for specific list with breadcrumbs

### Create Operations
- ✅ Create new task with all fields
- ✅ Validation errors on missing required fields
- ✅ Form prefills with list when on specific list

### Read Operations
- ✅ View all tasks across all lists
- ✅ View tasks for specific list
- ✅ View task details with comments and metadata
- ✅ Display breadcrumb navigation

### Update Operations
- ✅ Edit task details (title, status, priority, etc.)
- ✅ Save changes successfully
- ✅ Display validation errors on invalid input

### Delete Operations
- ✅ Delete task with confirmation
- ✅ Show success message after deletion

### Filtering & Search
- ✅ Filter tasks by status (todo, in_progress, completed)
- ✅ Filter tasks by priority (low, medium, high)
- ✅ Filter tasks by assignee
- ✅ Search tasks by title

### Data Display
- ✅ Show comments count
- ✅ Display task metadata (list, board, timestamps)
- ✅ Show assignee information
- ✅ Display status and priority badges

## Browser Output

When running tests, Chrome will:
1. Launch automatically
2. Navigate to localhost
3. Log in with test admin user
4. Perform CRUD operations
5. Close when test completes

To keep browser open for debugging:
```bash
# Add `binding.pry` in test to pause execution
# Browser will stay open until you continue in console
```

## Troubleshooting

### "Chrome is being controlled by automated test software"
This is normal - it's a security indicator showing Selenium is controlling the browser.

### ChromeDriver version mismatch
```bash
# Update webdrivers gem
bundle update webdrivers
```

### Tests timeout
Increase wait time in `spec/support/capybara.rb`:
```ruby
config.default_max_wait_time = 15 # increase from 10
```

### Database not clean between tests
Make sure `database_cleaner` is properly configured in `spec/support/capybara.rb`

## CI/CD Integration

For headless CI/CD (GitHub Actions, etc.):

```bash
HEADLESS=true bundle exec rspec spec/features/
```

And ensure `spec/support/capybara.rb` checks the `HEADLESS` env var:
```ruby
options.add_argument("--headless") if ENV["HEADLESS"]
```

## Best Practices

1. **Use descriptive scenario names** - Explains what is being tested
2. **One scenario per feature** - Test one user flow per scenario
3. **Use page helpers** - `expect(page).to have_content("text")`
4. **Test user workflows** - Don't test individual methods, test complete flows
5. **Keep tests fast** - Use `--headless` mode for speed
6. **Use factory fixtures** - Create test data with FactoryBot

## Debugging

Add debugging to tests:

```ruby
scenario "Admin can create task" do
  # ... test code ...

  # Take screenshot at any point
  save_screenshot("screenshot.png")

  # Print page HTML
  puts page.html

  # Pause and interact with browser
  binding.pry
end
```
