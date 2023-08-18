require 'vcr'
require 'webmock/rspec'

VCR.configure do |c|
  service_ports = [3018, 3019]
  c.cassette_library_dir = Rails.root.join('spec/vcr')
  c.hook_into :webmock
  # c.debug_logger = $stdout
  c.default_cassette_options = { match_requests_on: [:path] }
  c.configure_rspec_metadata!
  c.ignore_request do |request|
    chrome_urls = [
      'https://chromedriver.storage.googleapis.com',
      'https://googlechromelabs.github.io/',
      'https://edgedl.me.gvt1.com/',
    ]
    starts_with_chrome_url = chrome_urls.any? { |url| request.uri.start_with?(url) }

    if starts_with_chrome_url
      true
    else
      URI(request.uri).host.in?(%w[localhost 127.0.0.1]) &&
        service_ports.exclude?(URI(request.uri).port)
    end
  end
end
