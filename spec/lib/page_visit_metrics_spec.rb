require 'json'
require 'rspec'
require 'stringio'
require 'time'

require_relative '../../lib/page_visit_metrics'

RSpec.describe PageVisitMetrics do
  subject(:line) { JSON.parse(described_class.line_for(payload, environment: 'staging', catalogue:, now:)) }

  let(:catalogue) { described_class.catalogue }
  let(:now) { Time.utc(2026, 9, 28, 12) }
  let(:payload) do
    {
      controller: 'CommoditiesController',
      action: 'show',
      method: 'GET',
      path: '/commodities/0101210000',
      status: 200,
      format: 'html',
      request_id: 'req-1',
      browser_session_id: 'session-1',
      user_agent: 'Mozilla/5.0',
    }
  end

  it 'emits one request against the shared activity, coverage, status and page labels' do
    expect(line).to include(
      'Environment' => 'staging',
      'Service' => 'frontend',
      'Activity' => 'Commodities',
      'SessionCoverage' => 'With session ID',
      'StatusClass' => '2xx success',
      'Page' => 'Commodity code details',
      'PageMapping' => 'Mapped',
      'TariffPage' => 'Commodity code details',
      'PageRequests' => 1,
    ).and include('_aws' => include('CloudWatchMetrics' => include(
      include('Dimensions' => [%w[Environment Service Activity]]),
      include('Dimensions' => [%w[Environment Service TariffPage]]),
    )))
  end

  it 'keeps identifiers out of the metric line' do
    dimension_names = line.dig('_aws', 'CloudWatchMetrics').flat_map { |directive| directive['Dimensions'].flatten }

    expect(line.keys + dimension_names).not_to include('request_id', 'browser_session_id', 'path', 'user_agent')
  end

  it 'does not emit for a bot, a non-HTML request, an excluded controller or a missing request ID' do
    rejected = [
      payload.merge(user_agent: 'Googlebot'),
      payload.merge(format: 'json'),
      payload.merge(controller: 'HealthcheckController'),
      payload.merge(controller: 'Myott::DashboardController'),
      payload.merge(request_id: ''),
    ].map { |sample| described_class.line_for(sample, environment: 'staging', catalogue:, now:) }

    expect(rejected).to all(be_nil)
  end

  it 'keeps a request that has no user agent' do
    expect(described_class.line_for(payload.merge(user_agent: nil), environment: 'staging', catalogue:, now:)).not_to be_nil
  end

  it 'classifies each catalogue activity from its first matcher' do
    catalogue.fetch('activities').each do |activity|
      sample = sample_payload(activity)
      next unless sample

      emitted = JSON.parse(described_class.line_for(sample, environment: 'staging', catalogue:, now:))
      expect(emitted.fetch('Activity')).to eq(activity.fetch('label'))
    end
  end

  it 'uses the same tariff names as the catalogue' do
    emitted = catalogue.fetch('tariff_keys').to_h do |key|
      controller, action = key.split('#', 2)
      sample = JSON.parse(described_class.line_for(payload.merge(controller:, action:), environment: 'staging', catalogue:, now:))
      [key, sample.fetch('TariffPage')]
    end

    expected = catalogue.fetch('tariff_keys').each_with_object({}) do |key, names| # rubocop:disable Rails/IndexWith
      names[key] = catalogue.dig('page_names', key, 'name')
    end

    expect(emitted).to eq(expected)
  end

  it 'omits the tariff dimension for a commodity origin tab' do
    origin = JSON.parse(described_class.line_for(payload.merge(action: 'origin'), environment: 'staging', catalogue:, now:))

    expect(origin.slice('Activity', 'Page', 'TariffPage')).to eq(
      'Activity' => 'Help & guidance',
      'Page' => 'Rules of origin (commodity tab)',
    )
  end

  it 'labels a missing session, a redirect and a form submission together' do
    missing = JSON.parse(described_class.line_for(payload.merge(browser_session_id: nil, status: 302, method: 'POST'), environment: 'staging', catalogue:, now:))

    expect(missing).to include(
      'SessionCoverage' => 'Missing ID',
      'StatusClass' => '3xx redirects',
      'Page' => 'Commodity code details (form submission) (redirect)',
    )
  end

  it 'keeps an unknown page in the totals as unmapped' do
    unknown = JSON.parse(described_class.line_for(payload.merge(controller: 'ReportsController', action: 'index'), environment: 'staging', catalogue:, now:))

    expect(unknown.slice('Activity', 'Page', 'PageMapping', 'TariffPage')).to eq(
      'Activity' => 'Other pages',
      'Page' => 'Other public page (unmapped)',
      'PageMapping' => 'Unmapped',
    )
  end

  it 'names allowlisted enquiry steps without using the rest of the path' do
    emitted = JSON.parse(described_class.line_for(
                           payload.merge(
                             controller: 'ProductExperience::EnquiryFormController',
                             action: 'form',
                             path: '/xi/enquiry_form/goods_details?answer=private',
                             status: 200,
                           ),
                           environment: 'staging',
                           catalogue:,
                           now:,
                         ))

    expect(emitted).to include('Activity' => 'Enquiry form', 'Page' => 'Enquiry: Tell us about your goods', 'PageMapping' => 'Mapped')
  end

  it 'emits once when the exception page repeats the same request ID' do
    Thread.current[:page_visit_metrics_request_id] = nil
    output = instance_double(IO)
    allow(output).to receive(:write_nonblock) { |line, **| line.bytesize }
    event = Struct.new(:payload, :end).new(payload, now)

    expect([described_class.record(event, output:, environment: 'staging', catalogue:), described_class.record(event, output:, environment: 'staging', catalogue:)]).to eq([true, false])
  end

  it 'returns false when the write fails and does not raise' do
    output = instance_double(IO, write_nonblock: nil)
    event = Struct.new(:payload, :end).new(payload, now)

    expect(described_class.record(event, output:, environment: 'staging', catalogue:)).to be(false)
  end

  def sample_payload(activity)
    matcher = activity.fetch('matchers').first
    return if matcher.nil?

    case matcher.fetch('type')
    when 'page_key'
      controller, action = matcher.fetch('values').first.split('#', 2)
      payload.merge(controller:, action:)
    when 'controller'
      payload.merge(controller: matcher.fetch('values').first, action: 'index')
    when 'controller_prefix'
      payload.merge(controller: "#{matcher.fetch('values').first}ExampleController", action: 'index')
    end
  end
end
