require 'watir'
require 'axe-core-watir'

# Launch Browser
browser = Watir::Browser.new :chrome
browser.goto('https://example.com') # Replace with the URL you want to test

# Run Axe Accessibility Scan
axe = AxeCore::Watir::Script.new(browser)
results = axe.run

# Print Violations
puts "Accessibility Violations:"
puts results.violations

browser.close
