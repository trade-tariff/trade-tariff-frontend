require 'spec_helper'

RSpec.describe FeatureFlaggable, type: :controller do
  # Anonymous controller that includes the concern under test.
  # Rails' anonymous controller support gives us a real request cycle.
  controller(ApplicationController) do
    feature_gate :green_lanes, only: :gated
    feature_gate :welsh, only: :welsh_only

    def gated
      render plain: 'gated action'
    end

    def welsh_only
      render plain: 'welsh only action'
    end

    def open
      render plain: 'open action'
    end
  end

  before do
    routes.draw do
      get 'gated'     => 'anonymous#gated'
      get 'welsh_only' => 'anonymous#welsh_only'
      get 'open'      => 'anonymous#open'
    end
  end

  describe '.feature_gate' do
    context 'when the flag is enabled' do
      before { stub_feature_flag(:green_lanes, enabled: true) }

      it 'allows the gated action to proceed' do
        get :gated
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when the flag is disabled' do
      before { stub_feature_flag(:green_lanes, enabled: false) }

      it 'raises FeatureUnavailable for the gated action' do
        expect { get :gated }.to raise_error(TradeTariffFrontend::FeatureUnavailable)
      end
    end

    context 'with only: option — other actions are unaffected' do
      before { stub_feature_flag(:green_lanes, enabled: false) }

      it 'does not gate actions not listed in only:' do
        get :open
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with multiple feature_gate declarations on different actions' do
      # Proves that gates are independent: green_lanes on :gated does not bleed
      # into :welsh_only, and welsh on :welsh_only does not affect :gated.
      before do
        stub_feature_flag(:green_lanes, enabled: true)
        stub_feature_flag(:welsh, enabled: false)
      end

      it 'allows :gated when its flag (green_lanes) is on' do
        get :gated
        expect(response).to have_http_status(:ok)
      end

      it 'blocks :welsh_only when its flag (welsh) is off' do
        expect { get :welsh_only }.to raise_error(TradeTariffFrontend::FeatureUnavailable)
      end
    end
  end

  describe '#feature_enabled?' do
    before { stub_feature_flag(:green_lanes, enabled: true) }

    it 'returns true when the flag is on' do
      get :open
      expect(controller.feature_enabled?(:green_lanes)).to be true
    end
  end

  describe '#feature_disabled?' do
    before { stub_feature_flag(:green_lanes, enabled: false) }

    it 'returns true when the flag is off' do
      get :open
      expect(controller.feature_disabled?(:green_lanes)).to be true
    end
  end

  describe '#ld_anonymous_user_key' do
    # Use the gated action: feature_gate :green_lanes calls require_feature!
    # which calls feature_enabled? which calls ld_anonymous_user_key.
    before { stub_feature_flag(:green_lanes, enabled: true) }

    it 'generates a UUID and stores it in the session on the first flag check' do
      get :gated
      expect(session[:ld_anonymous_id]).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'reuses the same key across requests within the same session' do
      get :gated
      first_key = session[:ld_anonymous_id]

      get :gated
      expect(session[:ld_anonymous_id]).to eq(first_key)
    end
  end
end
