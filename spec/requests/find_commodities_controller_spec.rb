require 'spec_helper'

RSpec.describe FindCommoditiesController, type: :request do
  subject { response }

  describe 'GET #show' do
    include_context 'with latest news stubbed'
    include_context 'with news updates stubbed'

    before do
      get find_commodity_path(params)
    end

    let(:params) { {} }

    it { is_expected.to have_http_status :ok }
    it { is_expected.to have_attributes content_type: %r{text/html} }
    it { expect(response.body).not_to include('search_type_guided') }

    context 'when interactive search is enabled' do
      before do
        enable_feature(:interactive_search)
        get find_commodity_path
      end

      it { expect(response.body).to include('search_type_guided') }
    end

    context 'when interactive search is enabled on the XI service' do
      before do
        enable_feature(:interactive_search)
        get '/xi/find_commodity'
      end

      it { expect(response.body).not_to include('search_type_guided') }
    end

    context 'with a malformed search param' do
      let(:params) { { search: 'coffee beans' } }

      it { is_expected.to have_http_status :ok }
    end

    context 'with an invalid date flag' do
      let(:params) { { invalid_date: true, day: '22', month: '0', year: '2026' } }

      it { is_expected.to have_http_status :ok }

      it 'renders a GOV.UK error summary' do
        expect(response.body).to match(/govuk-error-summary.*You must enter a valid date/m)
      end

      it 'links the error summary to the date input' do
        expect(response.body).to match(/govuk-error-summary.*href="#search-as-of-field-error"/m)
      end

      it 'marks the date input as invalid' do
        expect(response.body).to match(/govuk-form-group--error.*id="search-as-of-field-error".*govuk-input--error/m)
      end

      it 'keeps the submitted date values in the form' do
        expect(response.body).to match(/name="search\[as_of\(3i\)\]"[^>]*value="22".*name="search\[as_of\(2i\)\]"[^>]*value="0".*name="search\[as_of\(1i\)\]"[^>]*value="2026"/m)
      end
    end

    context 'with a stale invalid date flag and corrected date values' do
      let(:params) { { invalid_date: true, day: '22', month: '7', year: '2026' } }

      it { is_expected.to have_http_status :ok }

      it 'does not render the invalid date summary' do
        expect(response.body).not_to match(/govuk-error-summary.*You must enter a valid date/m)
      end
    end
  end
end
