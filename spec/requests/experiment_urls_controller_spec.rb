require 'spec_helper'

RSpec.describe ExperimentUrlsController, type: :request do
  include_context 'with latest news stubbed'
  include_context 'with news updates stubbed'

  let(:experiment) { Rails.application.config.experiment_urls.fetch(:trusted_trader_guided_search) }

  context 'with a multi-feature experiment' do
    let(:features) { %w[interactive_search hybrid_search] }
    let(:experiment_overrides) { { features: } }
    let(:experiment) { Rails.application.config.experiment_urls.fetch(:hybrid_search_demo) }
    let(:disabled_flags) { [] }
    let(:evaluated_traits) { [] }

    before do
      config = Rails.application.config_for(:experiment_urls).deep_dup
      config.fetch(:hybrid_search_demo).except!(:feature).merge!(experiment_overrides)
      registry = TradeTariffFrontend::ExperimentUrls.new(
        config,
        registered_flags: TradeTariffFrontend::Config.registered_flags,
        service_names: %w[uk xi],
      )
      allow(Rails.application.config).to receive(:experiment_urls).and_return(registry)

      allow(FlagsmithClient.instance).to receive(:get_flags_for) do |_identity, traits|
        evaluated_traits << traits.deep_dup
        flags = features.index_with do |feature|
          traits.dig(feature, :value) == true && disabled_flags.exclude?(feature)
        end
        TestFlagsmithClient::TestFlags.new(flags)
      end
    end

    it 'enables every feature through its opt-in segment on later requests', :aggregate_failures do
      travel_to(Time.utc(2026, 10, 14, 12)) do
        get '/hybrid-search-demo'
        follow_redirect!

        expect(session[:experiment_url_optins]).to eq([experiment.enrollment_token])
        expect(Capybara.string(response.body)).to have_link('AI-assisted search')
        expect(evaluated_traits.last).to include(
          'interactive_search' => { value: true, transient: true },
          'hybrid_search' => { value: true, transient: true },
        )
      end
    end

    %w[interactive_search hybrid_search].each do |feature|
      it "unenrols when #{feature} is cleared and allows re-enrolment", :aggregate_failures do
        allow(FlagsmithManagementClient.instance).to receive(:get_traits_for).and_call_original

        travel_to(Time.utc(2026, 10, 14, 12)) do
          get '/hybrid-search-demo'
          follow_redirect!

          patch "/feature-flags/#{feature}", params: { enabled: 'false' }
          get find_commodity_path

          expect(session[:experiment_url_optins]).to be_empty
          expect(Capybara.string(response.body)).not_to have_link('AI-assisted search')
          features.each { |name| expect(evaluated_traits.last).not_to have_key(name) }

          get '/hybrid-search-demo'
          follow_redirect!

          expect(session[:experiment_url_optins]).to eq([experiment.enrollment_token])
          expect(Capybara.string(response.body)).to have_link('AI-assisted search')
          expect(FlagsmithManagementClient.instance).not_to have_received(:get_traits_for)
          expect(TEST_FLAGSMITH_MANAGEMENT_CLIENT.recorded_traits).to be_empty
        end
      end
    end

    it 'ignores old persisted false preferences' do
      cookies['flagsmith_anonymous_id'] = 'demo-browser'
      features.each do |feature|
        FlagsmithManagementClient.instance.set_trait('Anonymous:demo-browser', feature, false)
      end

      travel_to(Time.utc(2026, 10, 14, 12)) do
        get '/feature-flags'
        get '/hybrid-search-demo'
        follow_redirect!

        expect(Capybara.string(response.body)).to have_link('AI-assisted search')
      end
    end

    it 'keeps enrolment when clearing fails', :aggregate_failures do
      allow(FlagsmithManagementClient.instance).to receive(:delete_trait).and_raise(Faraday::TimeoutError)

      travel_to(Time.utc(2026, 10, 14, 12)) do
        get '/hybrid-search-demo'
        patch '/feature-flags/interactive_search', params: { enabled: 'false' }
        get find_commodity_path

        expect(session[:experiment_url_optins]).to eq([experiment.enrollment_token])
        expect(Capybara.string(response.body)).to have_link('AI-assisted search')
      end
    end

    it 'keeps experiments unrelated to the cleared feature', :aggregate_failures do
      travel_to(Time.utc(2026, 10, 14, 12)) do
        get '/search-beta-demo'
        get '/hybrid-search-demo'
        patch '/feature-flags/hybrid_search', params: { enabled: 'false' }
        get find_commodity_path

        expect(session[:experiment_url_optins]).to eq([
          Rails.application.config.experiment_urls.fetch(:search_beta_demo).enrollment_token,
        ])
        expect(Capybara.string(response.body)).to have_link('AI-assisted search')
        expect(evaluated_traits.last).not_to have_key('hybrid_search')
      end
    end

    it 'does not force AI search on when its flag remains disabled' do
      disabled_flags << 'interactive_search'

      travel_to(Time.utc(2026, 10, 14, 12)) do
        get '/hybrid-search-demo'
        follow_redirect!
      end

      expect(Capybara.string(response.body)).not_to have_link('AI-assisted search')
    end

    context 'when the experiment expires' do
      let(:experiment_overrides) { { features:, ends_on: '2026-10-14' } }

      it 'removes all transient opt-ins together', :aggregate_failures do
        travel_to(Time.utc(2026, 10, 14, 12)) do
          get '/hybrid-search-demo'
          follow_redirect!
          expect(Capybara.string(response.body)).to have_link('AI-assisted search')
        end

        travel_to(Time.utc(2026, 10, 14, 23)) { get find_commodity_path }

        expect(session[:experiment_url_optins]).to be_empty
        features.each { |name| expect(evaluated_traits.last).not_to have_key(name) }
        expect(Capybara.string(response.body)).not_to have_link('AI-assisted search')
      end

      it 'preserves a separate AI-search enrolment', :aggregate_failures do
        travel_to(Time.utc(2026, 10, 14, 12)) do
          get '/search-beta-demo'
          get '/hybrid-search-demo'
        end
        travel_to(Time.utc(2026, 10, 14, 23)) { get find_commodity_path }

        expect(evaluated_traits.last).to include('interactive_search' => { value: true, transient: true })
        expect(evaluated_traits.last).not_to have_key('hybrid_search')
        expect(Capybara.string(response.body)).to have_link('AI-assisted search')
        expect(Capybara.string(response.body)).to have_css('input[name="experiment"][value="demo"]', visible: :hidden)
      end
    end
  end

  context 'with the HMRC users experiment' do
    let(:experiment) { Rails.application.config.experiment_urls.fetch(:hmrc_users) }

    it 'enrols at the London start date', :aggregate_failures do
      travel_to(Time.utc(2026, 9, 13, 23)) do
        get '/hmrc-users', params: { experiment: 'spoofed' }
      end

      expect(response).to redirect_to('/find_commodity?experiment=hmrc-users')
      expect(session[:experiment_url_optins]).to eq([experiment.enrollment_token])
      expect(response.headers.fetch('Cache-Control')).to include('no-store')
    end

    it 'does not enrol before the start', :aggregate_failures do
      travel_to(Time.utc(2026, 9, 13, 22, 59, 59)) { get '/hmrc-users' }

      expect(response).to redirect_to('/find_commodity')
      expect(session[:experiment_url_optins]).to be_blank
    end

    it 'does not enrol Northern Ireland', :aggregate_failures do
      travel_to(Time.utc(2026, 9, 14, 12)) { get '/xi/hmrc-users' }

      expect(response).to redirect_to('/xi/find_commodity')
      expect(session[:experiment_url_optins]).to be_blank
    end

    it 'remains available without an end date', :aggregate_failures do
      travel_to(Time.utc(2036, 9, 14, 12)) { get '/hmrc-users' }

      expect(response).to redirect_to('/find_commodity?experiment=hmrc-users')
      expect(session[:experiment_url_optins]).to eq([experiment.enrollment_token])
    end
  end

  context 'with the HMRC traders experiment' do
    let(:experiment) { Rails.application.config.experiment_urls.fetch(:hmrc_traders) }

    it 'enrols at the London start date', :aggregate_failures do
      travel_to(Time.utc(2026, 9, 24, 23)) do
        get '/hmrc-traders', params: { experiment: 'spoofed' }
      end

      expect(response).to redirect_to('/find_commodity?experiment=hmrc-traders')
      expect(session[:experiment_url_optins]).to eq([experiment.enrollment_token])
      expect(response.headers.fetch('Cache-Control')).to include('no-store')
    end

    it 'does not enrol before the start', :aggregate_failures do
      travel_to(Time.utc(2026, 9, 24, 22, 59, 59)) { get '/hmrc-traders' }

      expect(response).to redirect_to('/find_commodity')
      expect(session[:experiment_url_optins]).to be_blank
    end

    it 'does not enrol Northern Ireland', :aggregate_failures do
      travel_to(Time.utc(2026, 9, 25, 12)) { get '/xi/hmrc-traders' }

      expect(response).to redirect_to('/xi/find_commodity')
      expect(session[:experiment_url_optins]).to be_blank
    end

    it 'remains available without an end date', :aggregate_failures do
      travel_to(Time.utc(2036, 9, 25, 12)) { get '/hmrc-traders' }

      expect(response).to redirect_to('/find_commodity?experiment=hmrc-traders')
      expect(session[:experiment_url_optins]).to eq([experiment.enrollment_token])
    end
  end

  context 'with the HMRC showcase experiment' do
    let(:experiment) { Rails.application.config.experiment_urls.fetch(:hmrc_showcase) }

    it 'enrols at the London start date', :aggregate_failures do
      travel_to(Time.utc(2026, 9, 27, 23)) do
        get '/hmrc-showcase', params: { experiment: 'spoofed' }
      end

      expect(response).to redirect_to('/find_commodity?experiment=hmrc-showcase')
      expect(session[:experiment_url_optins]).to eq([experiment.enrollment_token])
      expect(response.headers.fetch('Cache-Control')).to include('no-store')
    end

    it 'does not enrol before the start', :aggregate_failures do
      travel_to(Time.utc(2026, 9, 27, 22, 59, 59)) { get '/hmrc-showcase' }

      expect(response).to redirect_to('/find_commodity')
      expect(session[:experiment_url_optins]).to be_blank
    end

    it 'does not enrol Northern Ireland', :aggregate_failures do
      travel_to(Time.utc(2026, 9, 28, 12)) { get '/xi/hmrc-showcase' }

      expect(response).to redirect_to('/xi/find_commodity')
      expect(session[:experiment_url_optins]).to be_blank
    end

    it 'remains available without an end date', :aggregate_failures do
      travel_to(Time.utc(2036, 9, 28, 12)) { get '/hmrc-showcase' }

      expect(response).to redirect_to('/find_commodity?experiment=hmrc-showcase')
      expect(session[:experiment_url_optins]).to eq([experiment.enrollment_token])
    end
  end

  context 'with an old HMRC parcels link' do
    %w[uk xi].each do |service|
      it "opens the standard #{service} journey without enrolment", :aggregate_failures do
        get "/#{service}/hmrc-parcels"
        expect(response).to redirect_to(service == 'xi' ? '/xi/parcels-and-gifts' : '/parcels-and-gifts')
        follow_redirect!
        expect(response).to have_http_status(:ok)
        expect(Capybara.string(response.body)).to have_css('h1', text: 'What do you need help with?')
        expect(session[:experiment_url_optins]).to be_blank
      end
    end
  end

  context 'with the demo experiment' do
    let(:experiment) { Rails.application.config.experiment_urls.fetch(:search_beta_demo) }

    it 'enrols at the London start date', :aggregate_failures do
      travel_to(Time.utc(2026, 9, 9, 23)) do
        get '/search-beta-demo', params: { experiment: 'spoofed' }
      end

      expect(response).to redirect_to('/find_commodity?experiment=demo')
      expect(session[:experiment_url_optins]).to eq([experiment.enrollment_token])
      expect(response.headers.fetch('Cache-Control')).to include('no-store')
    end

    it 'does not enrol before the start', :aggregate_failures do
      travel_to(Time.utc(2026, 9, 9, 22, 59, 59)) { get '/search-beta-demo' }

      expect(response).to redirect_to('/find_commodity')
      expect(session[:experiment_url_optins]).to be_blank
    end

    it 'does not enrol Northern Ireland', :aggregate_failures do
      travel_to(Time.utc(2026, 9, 10, 12)) { get '/xi/search-beta-demo' }

      expect(response).to redirect_to('/xi/find_commodity')
      expect(session[:experiment_url_optins]).to be_blank
    end

    it 'remains available without an end date', :aggregate_failures do
      travel_to(Time.utc(2036, 9, 10, 12)) { get '/search-beta-demo' }

      expect(response).to redirect_to('/find_commodity?experiment=demo')
      expect(session[:experiment_url_optins]).to eq([experiment.enrollment_token])
    end
  end

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
    expect(Capybara.string(response.body)).to have_css('input[name="experiment"][value="tenpct"]', visible: :hidden)
  end
end
