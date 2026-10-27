RSpec.describe DutyCalculator::HomepageImportDetailsController, :user_session, type: :controller do
  render_views

  let(:user_session) { build(:duty_calculator_user_session) }
  let(:country) { DutyCalculator::Api::GeographicalArea.new(geographical_area_id: 'AR', description: 'Argentina') }

  include_context 'with UK service'

  before do
    allow(TradeTariffFrontend).to receive(:duty_calculator_homepage_card_enabled?).and_return(true)
    allow(DutyCalculator::Api::GeographicalArea).to receive(:list_countries).with(:uk).and_return([country])
  end

  describe 'GET #show' do
    before { get :show }

    it 'renders the UK homepage journey import details page', :aggregate_failures do
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Tell us about this import')
      expect(response.body).to include('Calculate duty for importing to England, Scotland or Wales (GB).')
      expect(response.body).to include('What is the country of origin?')
      expect(response.body).to include('Date of import')
      expect(response.body).to include('href="/find_commodity"')
      expect(assigns[:step].import_destination).to eq('UK')
      expect(assigns[:step].import_date).to eq(Time.zone.today)
    end
  end

  describe 'POST #create' do
    let(:params) do
      {
        duty_calculator_steps_import_details: {
          'import_date(3i)' => '27',
          'import_date(2i)' => '3',
          'import_date(1i)' => '2027',
          country_of_origin: 'AR',
        },
      }
    end

    it 'saves the answers and continues to the next homepage journey step', :aggregate_failures do
      post :create, params: params

      expect(response).to redirect_to(what_are_you_importing_path)
      expect(user_session.import_destination).to eq('UK')
      expect(user_session.country_of_origin).to eq('AR')
      expect(user_session.import_date).to eq(Date.new(2027, 3, 27))
    end
  end
end
