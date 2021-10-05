require 'spec_helper'

RSpec.describe CookiesHelper, type: :helper do
  describe '#policy_cookie' do
    it 'returns the parsed cookie value' do
      expect(helper.policy_cookie).to eq({})
    end

    context 'when the cookies policy is present' do
      let(:policy_cookie) do
        {
          settings: true,
          usage: 'true',
          remember_settings: 'true',
        }.to_json
      end

      let(:expected_policy_cookie) do
        {
          settings: true,
          usage: 'true',
          remember_settings: 'true',
        }.with_indifferent_access
      end

      before do
        helper.request.cookies['cookies_policy'] = policy_cookie
      end

      it 'returns the parsed cookie value' do
        expect(helper.policy_cookie).to eq(expected_policy_cookie)
      end
    end
  end

  describe '#preference_cookie' do
    it 'returns a nil' do
      expect(helper.preference_cookie).to be_nil
    end

    context 'when the cookies preference is present' do
      before do
        helper.request.cookies['cookies_preferences_set'] = 'true'
      end

      it 'returns the parsed cookie value' do
        expect(helper.preference_cookie).to eq('true')
      end
    end
  end

  describe '#updated_cookies?' do
    it 'returns nil' do
      expect(helper.updated_cookies?).to be_nil
    end

    context 'when ga_tracking is "true"' do
      before do
        controller.params['cookie_consent_usage'] = 'true'
      end

      it 'returns "true"' do
        expect(helper.updated_cookies?).to eq('true')
      end
    end

    context 'when ga_tracking is "false"' do
      before do
        controller.params['cookie_consent_usage'] = 'false'
      end

      it 'returns "false"' do
        expect(helper.updated_cookies?).to eq('false')
      end
    end

    context 'when remember_settings is "true"' do
      before do
        controller.params['cookie_remember_settings'] = 'true'
      end

      it 'returns true' do
        expect(helper.updated_cookies?).to eq('true')
      end
    end

    context 'when remember_settings is "false"' do
      before do
        controller.params['cookie_remember_settings'] = 'false'
      end

      it 'returns "false"' do
        expect(helper.updated_cookies?).to eq('false')
      end
    end
  end

  describe '#cookies_set?' do
    it 'returns false' do
      expect(helper).not_to be_cookies_set
    end

    context 'when both the cookies policy and cookies preference is present' do
      before do
        helper.request.cookies['cookies_policy'] = { 'foo' => 'bar' }.to_json
        helper.request.cookies['cookies_preferences_set'] = 'true'
      end

      it 'returns the parsed cookie value' do
        expect(helper).to be_cookies_set
      end
    end
  end

  describe '#usage_enabled?' do
    it 'returns false' do
      expect(helper.usage_enabled?).to be(false)
    end

    context 'when the policy cookie has cookie value set to "true"' do
      let(:policy_cookie) { { usage: 'true' }.to_json }

      before do
        helper.request.cookies['cookies_policy'] = policy_cookie
      end

      it 'returns true' do
        expect(helper.usage_enabled?).to be(true)
      end
    end
  end

  describe '#usage_disabled?' do
    it 'returns false' do
      expect(helper.usage_disabled?).to be(false)
    end

    context 'when the policy cookie has cookie value set to "false"' do
      let(:policy_cookie) { { usage: 'false' }.to_json }

      before do
        helper.request.cookies['cookies_policy'] = policy_cookie
      end

      it 'returns true' do
        expect(helper.usage_disabled?).to be(true)
      end
    end
  end

  describe '#remember_settings_enabled?' do
    it 'returns false' do
      expect(helper.remember_settings_enabled?).to be(false)
    end

    context 'when the policy cookie has cookie value set to "true"' do
      let(:policy_cookie) { { remember_settings: 'true' }.to_json }

      before do
        helper.request.cookies['cookies_policy'] = policy_cookie
      end

      it 'returns true' do
        expect(helper.remember_settings_enabled?).to be(true)
      end
    end
  end

  describe '#remember_settings_disabled?' do
    it 'returns false' do
      expect(helper.remember_settings_disabled?).to be(false)
    end

    context 'when the policy cookie has cookie value set to "true"' do
      let(:policy_cookie) { { remember_settings: 'false' }.to_json }

      before do
        helper.request.cookies['cookies_policy'] = policy_cookie
      end

      it 'returns true' do
        expect(helper.remember_settings_disabled?).to be(true)
      end
    end
  end
end
