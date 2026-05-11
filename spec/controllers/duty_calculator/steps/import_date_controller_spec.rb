RSpec.describe DutyCalculator::Steps::ImportDateController, :user_session do
  let(:user_session) { build(:duty_calculator_user_session, :with_country_of_origin, commodity_source: nil) }
  let(:commodity_code) { '01234567890' }
  let(:commodity) { attributes_for(:commodity, goods_nomenclature_item_id: commodity_code) }

  include_context 'with UK service'

  describe 'GET #show' do
    subject(:response) { get :show, params: { commodity_code: } }

    it 'assigns the correct step' do
      response
      expect(assigns[:step]).to be_a(DutyCalculator::Steps::ImportDate)
    end

    it { expect(response).to have_http_status(:ok) }
    it { expect(response).to render_template('import_date/show') }
    it { expect { response }.to change(user_session, :commodity_code).from(nil).to(commodity_code) }
    it { expect { response }.to change(user_session, :commodity_source).from(nil).to('uk') }
    it { expect { response }.to change(user_session, :referred_service).from(nil).to('uk') }
    it { expect { response }.to change(user_session, :country_of_origin).from('GB').to(nil) }
    it { expect { response }.to change(user_session, :import_date).from(nil).to(Time.zone.today) }

    context 'when the url path includes a day, month, year' do
      subject(:response) do
        get :show, params: {
          commodity_code:,
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
    subject(:response) { post :create, params: { commodity_code: }.merge(answers) }

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

      before do
        stub_api_request("commodities/#{commodity_code}")
          .with(query: { as_of: now })
          .to_return(jsonapi_response(:commodity, commodity))
      end

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

    context 'when the selected date is invalid for the commodity and validity periods are available' do
      let(:year) { now.year }
      let(:month) { now.month }
      let(:day) { now.day }
      let(:first_start_date) { Date.new(2024, 1, 1) }
      let(:first_end_date) { Date.new(2024, 12, 31) }
      let(:second_start_date) { Date.new(2025, 1, 1) }
      let(:validity_periods) do
        [
          attributes_for(
            :validity_period,
            goods_nomenclature_item_id: commodity_code,
            validity_start_date: first_start_date,
            validity_end_date: first_end_date,
          ),
          attributes_for(
            :validity_period,
            goods_nomenclature_item_id: commodity_code,
            validity_start_date: second_start_date,
            validity_end_date: nil,
          ),
        ]
      end

      before do
        stub_api_request("commodities/#{commodity_code}")
          .with(query: { as_of: now })
          .to_return(jsonapi_error_response(404))
        stub_api_request("commodities/#{commodity_code}/validity_periods")
          .with(query: { as_of: now })
          .to_return(jsonapi_response(:validity_periods, validity_periods))
      end

      it { expect(response).to have_http_status(:ok) }
      it { expect(response).to render_template('import_date/show') }
      it { expect { response }.not_to change(user_session, :import_date).from(nil) }

      it 'adds a date error' do
        response

        expect(assigns(:step).errors[:import_date]).to include(
          'The commodity code could not be found for this date. Enter a different date.',
        )
      end

      it 'assigns validity period start dates' do
        response

        expect(assigns(:commodity_validity_periods).map(&:start_date)).to eq([first_start_date, second_start_date])
      end

      it 'assigns validity period end dates' do
        response

        expect(assigns(:commodity_validity_periods).map(&:end_date)).to eq([first_end_date, nil])
      end
    end
  end
end
