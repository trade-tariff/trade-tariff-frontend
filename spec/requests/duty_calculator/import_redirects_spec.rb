require 'spec_helper'

RSpec.describe 'Duty calculator import redirects', type: :request do
  let(:commodity_code) { '0702000007' }
  let(:prefill) { { country: 'AR', day: '2', month: '10', year: '2026' } }

  %w[uk xi].each do |service|
    context "with the #{service} service" do
      let(:source_path) { "/#{service}/duty-calculator/#{commodity_code}/import-date" }
      let(:destination_path) { "#{service == 'xi' ? '/xi' : ''}/duty-calculator/#{commodity_code}/import-details" }

      it 'preserves country and date prefill without an opt-in' do
        get source_path, params: prefill

        expect(response).to redirect_to("#{destination_path}?#{prefill.to_query}")
      end

      it 'ignores user-supplied route options' do
        get source_path, params: prefill.merge(
          script_name: '//example.com',
          host: 'example.com',
          protocol: 'https',
          format: 'json',
          anchor: 'unexpected',
          extra: 'discard',
        )

        expect(response).to redirect_to("#{destination_path}?#{prefill.to_query}")
      end

      it 'ignores retired feature flag overrides' do
        stub_const('ENV', ENV.to_hash.merge('DUTY_CALCULATOR_UX_IMPROVEMENTS' => 'false'))
        get source_path, params: prefill

        expect(response).to redirect_to("#{destination_path}?#{prefill.to_query}")
      end
    end
  end
end
