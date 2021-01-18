require 'vcr'
require 'webmock/rspec'

VCR.configure do |c|
  service_ports = [3018, 3019]
  c.cassette_library_dir = Rails.root.join('spec', 'vcr')
  c.hook_into :webmock
  # c.debug_logger = $stdout
  c.default_cassette_options = { match_requests_on: [:path] }
  c.configure_rspec_metadata!
  c.ignore_request do |request|
    if request.uri.start_with?('https://chromedriver.storage.googleapis.com')
      true
    else
      URI(request.uri).host.in?(%w[localhost 127.0.0.1]) &&
        service_ports.exclude?(URI(request.uri).port)
    end
  end
end
