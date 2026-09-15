require 'spec_helper'

RSpec.describe 'Amplitude survey configuration', :aggregate_failures, type: :request do
  include_context 'with latest news stubbed'
  include_context 'with news updates stubbed'

  let(:api_key) { 'a' * 32 }
  let(:server_zone) { 'EU' }
  let(:instance_name) { '' }

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('AMPLITUDE_API_KEY').and_return(api_key)
    allow(ENV).to receive(:[]).with('AMPLITUDE_SERVER_ZONE').and_return(server_zone)
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch).with('AMPLITUDE_GTM_INSTANCE_NAME', '').and_return(instance_name)
    cookies['cookies_policy'] = { usage: true }.to_json
  end

  def survey_config
    node = Nokogiri::HTML(response.body).at_css('#amplitude-surveys-config')
    JSON.parse(node.text) if node
  end

  it 'renders the public project configuration for consented visitors' do
    get find_commodity_path

    expect(survey_config).to eq('apiKey' => api_key, 'serverZone' => 'EU', 'instanceName' => '')
    preloads = Nokogiri::HTML(response.body).css('link[rel="modulepreload"]').map { |node| node['href'] }
    expect(preloads).not_to include(a_string_matching(/amplitude-engagement/))
  end

  it 'makes SDK configuration available on non-search pages for preview' do
    get privacy_path

    expect(survey_config).to include('apiKey' => api_key)
  end

  it 'does not render configuration without consent' do
    cookies.delete('cookies_policy')
    get find_commodity_path

    expect(survey_config).to be_nil
  end

  [nil, 'invalid'].each do |invalid_key|
    it "omits configuration with project key #{invalid_key.inspect}" do
      allow(ENV).to receive(:[]).with('AMPLITUDE_API_KEY').and_return(invalid_key)
      get find_commodity_path
      expect(survey_config).to be_nil
    end
  end

  [nil, '', 'GB'].each do |invalid_zone|
    it "omits configuration with region #{invalid_zone.inspect}" do
      allow(ENV).to receive(:[]).with('AMPLITUDE_SERVER_ZONE').and_return(invalid_zone)
      get find_commodity_path
      expect(survey_config).to be_nil
    end
  end

  context 'with the US region' do
    let(:server_zone) { 'US' }

    it 'uses the configured region' do
      get find_commodity_path

      expect(survey_config).to include('serverZone' => 'US')
    end
  end

  context 'with a named GTM instance' do
    let(:instance_name) { '</script><script>alert(1)</script>' }

    it 'escapes the configuration without changing the instance name' do
      get find_commodity_path

      expect(survey_config).to include('instanceName' => instance_name)
      expect(response.body).not_to include(instance_name)
    end
  end
end
