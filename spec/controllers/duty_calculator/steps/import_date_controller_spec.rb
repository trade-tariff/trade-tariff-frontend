RSpec.describe DutyCalculator::Steps::ImportDateController, :user_session do
  let(:user_session) { build(:duty_calculator_user_session, :with_country_of_origin, commodity_source: nil) }
  let(:commodity_code) { '01234567890' }
  let(:referred_service) { 'uk' }

  describe 'GET #show' do
    subject(:response) { get :show, params: { commodity_code:, referred_service: } }

    it 'assigns the correct step' do
      response
      expect(assigns[:step]).to be_a(DutyCalculator::Steps::ImportDate)
    end

    it { expect(response).to have_http_status(:ok) }
    it { expect(response).to render_template('import_date/show') }
    it { expect { response }.to change(user_session, :commodity_code).from(nil).to(commodity_code) }
    it { expect { response }.to change(user_session, :commodity_source).from(nil).to(referred_service) }
    it { expect { response }.to change(user_session, :referred_service).from(nil).to(referred_service) }
    it { expect { response }.to change(user_session, :country_of_origin).from('GB').to(nil) }
    it { expect { response }.to change(user_session, :import_date).from(nil).to(Time.zone.today) }

    context 'when the url path includes a day, month, year' do
      subject(:response) do
        get :show, params: {
          commodity_code:,
          referred_service:,
          day:,
          month:,
          year:,
        }
      end

      let(:day) { '12' }
      let(:month) { '12' }
      let(:year) { 1.year.from_now.year.to_s }

      let(:expected) { Date.new(year.to_i, month.to_i, day.to_i) }

      it { expect { response }.to change(user_session, :import_date).from(nil).to(expected) }
    end
  end

  describe 'POST #create' do
    subject(:response) { post :create, params: { commodity_code:, referred_service: }.merge(answers) }

    let(:answers) do
      {
        duty_calculator_steps_import_date: {
          'import_date(3i)': day,
          'import_date(2i)': month,
          'import_date(1i)': year,
        },
      }
    end

    let(:now) { Date.current }

    context 'when the step answers are valid' do
      let(:year) { now.year }
      let(:month) { now.month }
      let(:day) { now.day }

      it 'assigns the correct step' do
        response
        expect(assigns[:step]).to be_a(DutyCalculator::Steps::ImportDate)
      end

      it { expect(response).to redirect_to(import_destination_path) }
      it { expect { response }.to change(user_session, :import_date).from(nil).to(now) }
    end

    context 'when the step answers are invalid' do
      let(:year) { now.year }
      let(:month) { '' }
      let(:day) { '' }

      it 'assigns the correct step' do
        response
        expect(assigns[:step]).to be_a(DutyCalculator::Steps::ImportDate)
      end

      it { is_expected.to have_http_status(:ok) }
      it { expect { response }.not_to change(user_session, :import_date).from(nil) }
    end
  end
end
