RSpec.describe DutyCalculator::Steps::ImportDetailsController, :user_session do
  render_views

  let(:user_session) { build(:duty_calculator_user_session, commodity_source: nil) }
  let(:commodity_code) { '0702000007' }
  let(:commodity_attributes) { attributes_for(:commodity, goods_nomenclature_item_id: commodity_code) }
  let(:commodity) { DutyCalculator::Api::Commodity.new(commodity_attributes) }
  let(:ux_improvements) { true }

  include_context 'with UK service'

  before do
    allow(TradeTariffFrontend).to receive(:duty_calculator_ux_improvements?).and_return(ux_improvements)
    allow(controller).to receive(:commodity).and_return(commodity)
  end

  describe 'GET #show' do
    subject(:response) { get :show, params: { commodity_code: } }

    before do
      allow(Commodity).to receive(:find).and_return(commodity)
    end

    it { expect(response).to have_http_status(:ok) }
    it { expect(response).to render_template('import_details/show') }
    it { expect(response.body).to include('Tell us about this import') }
    it { expect(response.body).to include('Calculate import costs') }
    it { expect(response.body).to include('data-country-lists=') }
    it { expect { response }.to change(user_session, :commodity_code).from(nil).to(commodity_code) }
    it { expect { response }.not_to change(user_session, :import_date) }

    it 'shows today as the date' do
      response

      expect(assigns[:step].import_date).to eq(Time.zone.today)
    end

    context 'when the commodity page passes a different date for a commodity with answers' do
      subject(:response) { get :show, params: { commodity_code:, day: '2', month: '10', year: '2026' } }

      let(:user_session) do
        build(:duty_calculator_user_session, :with_commodity_information, import_date: '2026-09-01', import_destination: 'UK', country_of_origin: 'AR')
      end

      it { expect { response }.not_to change(user_session, :import_date) }

      it 'shows the new date' do
        response

        expect(assigns[:step].import_date).to eq(Date.new(2026, 10, 2))
      end
    end

    context 'when the commodity is not available on the date' do
      before do
        allow(Commodity).to receive(:find).and_raise(Faraday::ResourceNotFound, 'not found')
        allow(ValidityPeriod).to receive(:all).and_return([])
      end

      it { expect(response.body).to include('The commodity code could not be found for this date') }
    end

    it 'selects GB by default' do
      response

      expect(assigns[:step].import_destination).to eq('UK')
    end

    context 'when the commodity page passes a country' do
      subject(:response) { get :show, params: { commodity_code:, country: 'EG' } }

      it 'pre-fills the country of origin' do
        response

        expect(assigns[:step].country_of_origin).to eq('EG')
      end
    end

    context 'when the session already has answers for this commodity' do
      let(:user_session) do
        build(
          :duty_calculator_user_session,
          :with_commodity_information,
          import_date: '2026-09-01',
          import_destination: 'XI',
          country_of_origin: 'OTHER',
          other_country_of_origin: 'AR',
        )
      end

      it 'pre-fills the previous answers', :aggregate_failures do
        response

        expect(assigns[:step].import_date).to eq(Date.new(2026, 9, 1))
        expect(assigns[:step].import_destination).to eq('XI')
        expect(assigns[:step].country_of_origin).to eq('AR')
      end
    end

    context 'when the feature switch is off' do
      let(:ux_improvements) { false }

      it { expect(response).to redirect_to(import_date_path(commodity_code:)) }
    end

    context 'when the trader came from Check your answers' do
      let(:user_session) { build(:duty_calculator_user_session, :with_commodity_information, return_to_confirm: true) }

      it { expect(response.body).to include("href=\"#{confirm_path}\"") }
    end
  end

  describe 'POST #create' do
    subject(:response) { post :create, params: { commodity_code:, duty_calculator_steps_import_details: answers } }

    let(:user_session) { build(:duty_calculator_user_session, :with_commodity_information) }
    let(:answers) do
      {
        'import_date(3i)' => '1',
        'import_date(2i)' => '9',
        'import_date(1i)' => '2026',
        'import_destination' => 'UK',
        'country_of_origin' => country_of_origin,
      }
    end
    let(:country_of_origin) { 'AR' }

    before do
      stub_api_request("commodities/#{commodity_code}")
        .with(query: { as_of: Date.new(2026, 9, 1) })
        .to_return(jsonapi_response(:commodity, commodity_attributes))
    end

    context 'when the answers are valid' do
      it { expect(response).to redirect_to(customs_value_path) }
      it { expect { response }.to change(user_session, :country_of_origin).from(nil).to('AR') }
      it { expect { response }.to change(user_session, :import_destination).from(nil).to('UK') }
    end

    context 'when the answers are invalid' do
      let(:country_of_origin) { '' }

      it { expect(response).to have_http_status(:ok) }
      it { expect(response).to render_template('import_details/show') }
      it { expect(response.body).to include('Enter a valid origin for this import') }
      it { expect { response }.not_to change(user_session, :country_of_origin) }
    end

    context 'when returning from Check your answers without a change' do
      let(:user_session) do
        build(
          :duty_calculator_user_session,
          :with_commodity_information,
          import_date: '2026-09-01',
          import_destination: 'UK',
          country_of_origin: 'AR',
          return_to_confirm: true,
        )
      end

      it { expect(response).to redirect_to(confirm_path) }
    end

    context 'when importing into Northern Ireland from the rest of the world' do
      let(:answers) { super().merge('import_destination' => 'XI', 'country_of_origin' => 'EG') }
      let(:user_session) do
        build(
          :duty_calculator_user_session,
          :with_commodity_information,
          import_destination: 'XI',
          country_of_origin: 'OTHER',
          other_country_of_origin: 'AR',
          commodity_source: 'xi',
        )
      end
      let(:lookups) { [] }

      before do
        allow(DutyCalculator::Api::GeographicalArea).to receive(:eu_member?).and_return(false)
        allow(DutyCalculator::Api::Commodity).to receive(:build) do |source, _code, query|
          lookups << [source, query]
          instance_double(DutyCalculator::Api::Commodity, trade_defence: false, zero_mfn_duty: true)
        end
      end

      it 'looks up the Northern Ireland route details for the new origin and date' do
        response

        expect(lookups).to include(['xi', { 'as_of' => '2026-09-01', 'filter[geographical_area_id]' => 'EG' }])
      end

      context 'when the Northern Ireland lookup fails' do
        before do
          allow(DutyCalculator::Api::Commodity).to receive(:build).and_raise(Faraday::ResourceNotFound, 'not found')
          allow(ValidityPeriod).to receive(:all).and_return([])
        end

        it { expect(response.body).to include('The commodity code could not be found for this date') }
        it { expect { response }.not_to change(user_session, :other_country_of_origin).from('AR') }
      end

      it { expect(response).to redirect_to(customs_value_path) }
      it { expect { response }.to change(user_session, :commodity_source).from('xi').to('uk') }

      context 'when returning from Check your answers without a change' do
        let(:user_session) do
          build(
            :duty_calculator_user_session,
            :with_commodity_information,
            import_date: '2026-09-01',
            import_destination: 'XI',
            country_of_origin: 'OTHER',
            other_country_of_origin: 'EG',
            commodity_source: 'xi',
            return_to_confirm: true,
          )
        end

        it { expect(response).to redirect_to(confirm_path) }
        it { expect { response }.to change(user_session, :commodity_source).from('xi').to('uk') }
      end
    end

    context 'when only the date is different from the saved answers' do
      let(:answers) { super().merge('import_date(3i)' => '2', 'import_date(2i)' => '10') }
      let(:user_session) do
        build(:duty_calculator_user_session, :with_commodity_information, :with_vat, import_date: '2026-09-01', import_destination: 'UK', country_of_origin: 'AR')
      end

      before do
        stub_api_request("commodities/#{commodity_code}")
          .with(query: { as_of: Date.new(2026, 10, 2) })
          .to_return(jsonapi_response(:commodity, commodity_attributes))
      end

      it 'clears the answers that depend on the date' do
        expect { response }.to change(user_session, :vat).to(nil)
      end
    end

    context 'when returning from Check your answers with a change' do
      let(:user_session) do
        build(
          :duty_calculator_user_session,
          :with_commodity_information,
          import_date: '2026-09-01',
          import_destination: 'UK',
          country_of_origin: 'EG',
          return_to_confirm: true,
        )
      end

      it { expect(response).to redirect_to(customs_value_path) }
    end
  end
end
