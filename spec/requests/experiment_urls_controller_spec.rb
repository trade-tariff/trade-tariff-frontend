require 'spec_helper'

RSpec.describe ExperimentUrlsController, type: :request do
  include_context 'with latest news stubbed'
  include_context 'with news updates stubbed'

  let(:experiment) { Rails.application.config.experiment_urls.fetch(:trusted_trader_guided_search) }

  it 'enrols the active browser, redirects with its trusted label, and is not cacheable', :aggregate_failures do
    allow(FlagsmithClient.instance).to receive(:get_flags_for).and_call_original
    travel_to(Time.utc(2026, 7, 27, 12)) { get experiment.path, params: { experiment: 'spoofed' } }
    expect(session[:experiment_url_optins]).to eq([experiment.enrollment_token])
    expect(response).to redirect_to('/find_commodity?experiment=trstd-trdr')
    expect(response.headers.fetch('Cache-Control')).to include('no-store')
    expect(TEST_FLAGSMITH_MANAGEMENT_CLIENT.recorded_traits).to be_empty
    expect(FlagsmithClient.instance).not_to have_received(:get_flags_for)
  end

  it 'uses inclusive London dates and refuses the wrong service', :aggregate_failures do
    starts_at = experiment.starts_on.in_time_zone(experiment.timezone)
    expires_at = (experiment.ends_on + 1.day).in_time_zone(experiment.timezone)
    cases = {
      starts_at - 1.second => '/find_commodity',
      starts_at => '/find_commodity?experiment=trstd-trdr',
      expires_at - 1.second => '/find_commodity?experiment=trstd-trdr',
      expires_at => '/find_commodity',
    }
    cases.each do |time, location|
      travel_to(time) { get experiment.path }
      expect(response).to redirect_to(location)
      session.delete(:experiment_url_optins)
    end
    travel_to(starts_at) { get "/xi#{experiment.path}" }
    expect(response).to redirect_to('/xi/find_commodity')
  end

  it 'is idempotent and replaces malformed or stale enrolment storage' do
    controller = described_class.new
    storage = { experiment_url_optins: ['stale', experiment.enrollment_token, experiment.enrollment_token] }
    allow(described_class).to receive(:new).and_return(controller)
    allow(controller).to receive(:session).and_return(storage)
    travel_to(Time.utc(2026, 7, 27, 12)) { 2.times { get experiment.path } }
    expect(storage[:experiment_url_optins]).to eq([experiment.enrollment_token])
  end

  it 'replaces non-array enrolment storage during an active visit' do
    [{ unexpected: 'shape' }, 'legacy'].each do |malformed|
      controller = described_class.new
      storage = { experiment_url_optins: malformed }
      allow(described_class).to receive(:new).and_return(controller)
      allow(controller).to receive(:session).and_return(storage)
      travel_to(Time.utc(2026, 7, 27, 12)) { get experiment.path }
      expect(storage[:experiment_url_optins]).to eq([experiment.enrollment_token])
    end
  end

  it 'carries only a validated active label into guided search', :aggregate_failures do
    enable_feature(:interactive_search)
    travel_to(Time.utc(2026, 7, 27, 12)) do
      get experiment.path
      follow_redirect!
    end
    expect(Capybara.string(response.body)).to have_css('input[name="experiment"][value="trstd-trdr"]', visible: :hidden)

    travel_to(experiment.starts_on.in_time_zone(experiment.timezone) - 1.second) do
      get '/find_commodity', params: { experiment: 'spoofed' }
    end
    expect(Capybara.string(response.body)).to have_no_css('input[name="experiment"]', visible: :hidden)
  end
end
