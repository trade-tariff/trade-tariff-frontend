require 'spec_helper'

RSpec.describe CspReportsController, type: :request do
  describe 'POST /csp-violation-report' do
    let(:report) do
      {
        'csp-report' => {
          'document-uri' => 'https://www.trade-tariff.service.gov.uk/commodities/0101210000',
          'effective-directive' => 'script-src-elem',
          'blocked-uri' => 'inline',
        },
      }.to_json
    end

    before do
      allow(Rails.logger).to receive(:warn).and_call_original
      allow(NewRelic::Agent).to receive(:notice_error)
    end

    def post_report(body)
      post '/csp-violation-report', params: body, headers: { 'CONTENT_TYPE' => 'application/csp-report' }
    end

    it 'returns 200' do
      post_report(report)

      expect(response).to have_http_status(:ok)
    end

    it 'logs the report body' do
      post_report(report)

      expect(Rails.logger).to have_received(:warn).with("CSP Violation: #{report}").once
    end

    # Each report was a New Relic error. Reports are not application errors,
    # and they were 99.9% of the frontend's errors in New Relic.
    it 'does not send the report to New Relic as an error' do
      post_report(report)

      expect(NewRelic::Agent).not_to have_received(:notice_error)
    end

    it 'logs no more than the first 4 KB of the body' do
      post_report('a' * 10_000)

      expect(Rails.logger).to have_received(:warn).with("CSP Violation: #{'a' * 4096}").once
    end
  end
end
