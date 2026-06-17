require 'spec_helper'

RSpec.describe SearchController, type: :controller, vcr: { cassette_name: 'search#quota_search', allow_playback_repeats: true } do
  before { TradeTariffFrontend::ServiceChooser.service_choice = nil }

  describe '#quota_search' do
    context 'with xi as the service choice' do
      let :request_page do
        allow(TradeTariffFrontend::ServiceChooser).to receive(:xi?).and_return(true)
        TradeTariffFrontend::ServiceChooser.service_choice = 'xi'

        get :quota_search, params: { goods_nomenclature_item_id: '0301919011' }, format: :html
      end

      it { expect { request_page }.to raise_exception TradeTariffFrontend::FeatureUnavailable }
    end

    context 'without search params' do
      render_views

      before do
        get :quota_search, format: :html
      end

      it { is_expected.to respond_with(:success) }

      it 'displays no results' do
        expect(response.body).not_to match(/Quota search results/)
      end
    end

    context 'when searching by goods nomenclature' do
      render_views

      before do
        get :quota_search, params: { goods_nomenclature_item_id: '0301919011' }, format: :html
      end

      it { is_expected.to respond_with(:success) }

      it 'displays results' do
        expect(response.body).to match(/Quota search results/)
      end
    end

    context 'when searching by origin' do
      render_views

      before do
        get :quota_search, params: { geographical_area_id: '1011' }, format: :html
      end

      it { is_expected.to respond_with(:success) }

      it 'displays results' do
        expect(response.body).to match(/Quota search results/)
      end
    end

    context 'when searching by order number' do
      render_views

      before do
        get :quota_search, params: { order_number: '090671' }, format: :html
      end

      it { is_expected.to respond_with(:success) }

      it 'displays results' do
        expect(response.body).to match(/Quota search results/)
      end
    end

    context 'when searching by critical flag' do
      render_views

      before do
        get :quota_search, params: { critical: 'Y' }, format: :html
      end

      it { is_expected.to respond_with(:success) }

      it 'displays results' do
        expect(response.body).to match(/Quota search results/)
      end
    end

    context 'when searching by status' do
      render_views

      before do
        get :quota_search, params: { status: 'Not blocked' }, format: :html
      end

      it { is_expected.to respond_with(:success) }

      it 'displays results' do
        expect(response.body).to match(/Quota search results/)
      end
    end

    context 'when searching by date' do
      render_views

      before do
        get :quota_search, params: { day: '01', month: '01', year: '2019' }, format: :html
      end

      it { is_expected.to respond_with(:success) }

      it 'restricts search by year only' do
        expect(response.body).to match(/Sorry, there is a problem with the search query. Please specify one or more search criteria./)
      end
    end

    context 'when date is submitted via nested as_of params' do
      before do
        get :quota_search,
            params: {
              quota_search_form: {
                'as_of(3i)' => '01',
                'as_of(2i)' => '01',
                'as_of(1i)' => '2019',
              },
            },
            format: :html
      end

      it 'redirects to canonical day, month, year query params' do
        expect(response).to redirect_to(quota_search_path(day: '01', month: '01', year: '2019'))
      end
    end

    context 'with an invalid date' do
      render_views

      before do
        get :quota_search, params: { day: '31', month: '2', year: '2023', new_search: 'Submit' }, format: :html
      end

      it 'renders a GOV.UK error summary' do
        expect(response.body).to match(/govuk-error-summary.*You must enter a valid date/m)
      end

      it 'links the error summary to the date input' do
        expect(response.body).to match(/govuk-error-summary.*href="#quota-search-form-as-of-field-error"/m)
      end

      it 'marks the date input as invalid' do
        expect(response.body).to match(/govuk-form-group--error.*id="quota-search-form-as-of-field-error".*govuk-input--error/m)
      end
    end
  end
end
