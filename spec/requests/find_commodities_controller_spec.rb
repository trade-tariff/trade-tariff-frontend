require 'spec_helper'

RSpec.describe FindCommoditiesController, type: :request do
  subject { response }

  describe 'GET #show' do
    include_context 'with latest news stubbed'
    include_context 'with news updates stubbed'

    before { get find_commodity_path(params) }

    let(:params) { {} }

    it { is_expected.to have_http_status :ok }
    it { is_expected.to have_attributes content_type: %r{text/html} }

    context 'with a malformed search param' do
      let(:params) { { search: 'coffee beans' } }

      it { is_expected.to have_http_status :ok }
    end

    context 'with an invalid date flag' do
      let(:params) { { invalid_date: true, day: '22', month: '0', year: '2026' } }

      it 'renders a GOV.UK error summary' do
        expect(response.body).to match(/govuk-error-summary.*You must enter a valid date/m)
      end

      it 'links the error summary to the date input' do
        expect(response.body).to match(/govuk-error-summary.*href="#day"/m)
      end

      it 'marks the date input as invalid' do
        expect(response.body).to match(/govuk-form-group--error.*id="day".*govuk-input--error/m)
      end

      it 'keeps the submitted date values in the form' do
        expect(response.body).to match(/id="day"[^>]*value="22".*id="month"[^>]*value="0".*id="year"[^>]*value="2026"/m)
      end
    end
  end
end
