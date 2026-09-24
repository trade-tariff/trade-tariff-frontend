RSpec.describe Flagsmith::OptInPreferences do
  before do
    Current.flagsmith_identity = Flagsmith::AnonymousIdentity.new('abc123')
  end

  it 'only forwards boolean preferences for registered opt-in features' do
    allow(FlagsmithManagementClient.instance).to receive(:get_traits_for)
      .and_return('interactive_search' => false, 'webchat' => true, 'request_country' => 'gb', 'unknown' => true)

    expect(described_class.current).to eq('interactive_search' => false)
  end

  it 'does not interpret strings as a saved boolean preference' do
    allow(FlagsmithManagementClient.instance).to receive(:get_traits_for)
      .and_return('interactive_search' => 'true')

    expect(described_class.current).to eq({})
  end

  it 'reads core only once per request even for an empty preference' do
    allow(FlagsmithManagementClient.instance).to receive(:get_traits_for).and_return({})
    2.times { described_class.current }

    expect(FlagsmithManagementClient.instance).to have_received(:get_traits_for).once
  end

  it 'does not retry a failed read in the same request', :aggregate_failures do
    allow(FlagsmithManagementClient.instance).to receive(:get_traits_for).and_raise(Faraday::TimeoutError)
    2.times { expect { described_class.current }.to raise_error(Faraday::TimeoutError) }

    expect(FlagsmithManagementClient.instance).to have_received(:get_traits_for).once
  end
end
