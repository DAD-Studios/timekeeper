# Configure Capybara to use headless Chrome for feature tests
require 'capybara/rspec'

# Check if Chrome is available - use a constant to cache the result
# Note: We only check for google-chrome, not chromium-browser, because
# chromium-browser in WSL often doesn't work properly without additional configuration
CHROME_AVAILABLE = begin
  # Try to find Chrome binary (google-chrome only for WSL compatibility)
  chrome_bin = `which google-chrome 2>/dev/null`.strip
  !chrome_bin.empty?
rescue
  false
end

# Only register Chrome driver if Chrome is available
if CHROME_AVAILABLE
  Capybara.register_driver :headless_chrome do |app|
    options = Selenium::WebDriver::Chrome::Options.new

    # Set Chrome binary location explicitly for WSL
    chrome_bin = `which google-chrome-stable google-chrome 2>/dev/null`.lines.first&.strip
    options.binary = chrome_bin if chrome_bin && !chrome_bin.empty?

    options.add_argument('--headless')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')
    options.add_argument('--disable-gpu')
    options.add_argument('--window-size=1400,900')

    Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
  end

  Capybara.javascript_driver = :headless_chrome
else
  # Chrome not available - JS tests will be skipped
  puts "\n⚠️  Chrome not found - JavaScript tests (js: true) will be skipped"
  puts "   To run JS tests, install Chrome: see README.md for instructions\n\n"

  # Configure a dummy JS driver that skips tests
  Capybara.javascript_driver = :rack_test
end

Capybara.default_driver = :rack_test
Capybara.server = :puma, { Silent: true }

# Configure RSpec to skip JS tests when Chrome is not available or not working
RSpec.configure do |config|
  config.before(:each, type: :feature, js: true) do
    unless CHROME_AVAILABLE
      skip "Chrome not installed - skipping JavaScript test"
    end

    # Additional check for WSL: Chrome may be installed but unable to run without X server
    if ENV['WSL_DISTRO_NAME'] || ENV['WSL_INTEROP']
      begin
        # Quick check if Chrome can actually start
        `timeout 2 google-chrome --headless --no-sandbox --disable-gpu --version 2>&1`
        skip "Chrome installed but cannot run in WSL without X server - skipping JavaScript test" unless $?.success?
      rescue
        skip "Chrome verification failed - skipping JavaScript test"
      end
    end
  end
end
