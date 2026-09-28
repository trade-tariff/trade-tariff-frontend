require 'spec_helper'

RSpec.describe 'Page visit metrics', type: :request do
  it 'counts an HTML exception once when the error page repeats the request' do
    lines = []
    output = instance_double(IO)
    allow(output).to receive(:write_nonblock) do |line, **|
      lines << line
      line.bytesize
    end
    PageVisitMetrics.subscribe!(output:, environment: 'test')
    PagesController.class_eval do
      alias_method :privacy_without_page_visit_probe, :privacy
      define_method(:privacy) { raise StandardError, 'boom' }
    end

    get privacy_path

    expect(lines.size).to eq(1)
  ensure
    if PagesController.method_defined?(:privacy_without_page_visit_probe)
      PagesController.class_eval do
        alias_method :privacy, :privacy_without_page_visit_probe
        remove_method :privacy_without_page_visit_probe
      end
    end
    PageVisitMetrics.unsubscribe!
    Thread.current[:page_visit_metrics_request_id] = nil
  end
end
