# Real local search with explicitly illustrative activity messages.
# bundle exec puma script/demos/guided_search_live.ru -b tcp://127.0.0.1:3001 -w 0
abort 'This prototype cannot run in production' if ENV['RAILS_ENV'] == 'production'

ENV['RAILS_ENV'] = 'development'
ENV['ENVIRONMENT'] = 'development'
ENV['INTERACTIVE_SEARCH'] = 'true'
ENV['BASIC_PASSWORD'] = ''
ENV['FLAGSMITH_ENVIRONMENT_KEY'] = ''
ENV['API_SERVICE_BACKEND_URL_OPTIONS'] = '{"uk":"http://localhost:3000/uk/api","xi":"http://localhost:3000/xi/api"}'
ENV['BACKEND_BASE_DOMAIN'] = 'http://localhost:3000/'

require_relative '../../config/environment'

# Keep illustrative timing out of normal Rails rendering and the API contract.
# There are no backend stubs and no delay to completion in this recording mode.
class GuidedSearchLivePreview
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)
    return [status, headers, body] unless headers['content-type']&.include?('text/html')

    html = +''
    body.each { |part| html << part }
    body.close if body.respond_to?(:close)
    html.gsub!('data-controller="guided-search-loading"',
               'data-controller="guided-search-loading" data-guided-search-loading-illustrative-value="true"')
    headers.delete('content-length')
    [status, headers, [html]]
  end
end

use GuidedSearchLivePreview
run Rails.application
