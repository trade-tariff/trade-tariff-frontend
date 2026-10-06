require 'spec_helper'

RSpec.describe 'Duty calculator import redirects', type: :request do
  include_context 'with UK service'

  let(:commodity_code) { '0702000007' }
  let(:prefill) { { country: 'AR', day: '2', month: '10', year: '2026' } }

  [
    [true, 'import-date', 'import-details'],
    [false, 'import-details', 'import-date'],
  ].each do |enabled, source, destination|
    context "when redirecting from #{source} to #{destination}" do
      before do
        allow(TradeTariffFrontend).to receive(:duty_calculator_ux_improvements?).and_return(enabled)
      end

      let(:source_path) { "/duty-calculator/#{commodity_code}/#{source}" }
      let(:destination_path) { "/duty-calculator/#{commodity_code}/#{destination}" }

      it 'preserves country and date prefill' do
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
    end
  end
end
