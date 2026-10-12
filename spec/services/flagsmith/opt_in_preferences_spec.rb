RSpec.describe Flagsmith::OptInPreferences do
  describe '.filter' do
    it 'keeps only registered boolean preferences' do
      expect(described_class.filter(
               interactive_search: false, parcel_gift_journey: 'true', webchat: true, request_country: 'gb',
             )).to eq('interactive_search' => false)
    end
  end

  describe '#read' do
    subject(:preferences) do
      described_class.new(cookies:, session:, identity: Flagsmith::AnonymousIdentity.new('abc123'), migrate_session: true)
    end

    let(:cookies) { ActionDispatch::Request.new(Rails.application.env_config.dup).cookie_jar }
    let(:session) { { flagsmith_optin_traits: { interactive_search: true } } }

    before do
      cookies[:flagsmith_anonymous_id] = 'abc123'
    end

    it 'keeps the session if the cookie write fails', :aggregate_failures do
      allow(cookies.signed).to receive(:[]=).and_raise(ActionDispatch::Cookies::CookieOverflow)

      expect { preferences.read }.to raise_error(ActionDispatch::Cookies::CookieOverflow)
      expect(session[:flagsmith_optin_traits]).to eq(interactive_search: true)
    end

    it 'writes a secure cookie in production' do
      allow(Rails.env).to receive(:production?).and_return(true)
      allow(cookies.signed).to receive(:[]=).and_call_original

      preferences.read

      expect(cookies.signed).to have_received(:[]=)
        .with(described_class::COOKIE_NAME, hash_including(secure: true, httponly: true, same_site: :lax))
    end
  end
end
