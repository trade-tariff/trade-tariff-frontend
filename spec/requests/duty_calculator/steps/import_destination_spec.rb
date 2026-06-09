require 'spec_helper'

RSpec.describe 'Duty calculator import destination step', :aggregate_failures, :user_session, type: :request do
  let(:user_session) { build(:duty_calculator_user_session, :with_commodity_information) }

  describe 'GET /duty-calculator/import-destination' do
    it 'returns success and includes the page title' do
      get import_destination_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Which part of the UK are you importing into?')
      expect(response.body).to include('Which part of the UK are you importing into - Online Tariff Duty calculator')
    end
  end

  describe 'POST /duty-calculator/import-destination' do
    let(:params) do
      {
        duty_calculator_steps_import_destination: {
          import_destination: import_destination,
        },
      }
    end

    context 'when params are valid' do
      let(:import_destination) { 'GB' }

      it 'redirects to the next step and persists the answer' do
        expect {
          post import_destination_path, params:
        }.to change(user_session, :import_destination).from(nil).to('GB')

        expect(response).to redirect_to(country_of_origin_path)
      end
    end

    context 'when params are invalid' do
      let(:import_destination) { '' }

      it 're-renders the step page and keeps the page title' do
        post import_destination_path, params: params

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('There is a problem')
        expect(response.body).to include('Which part of the UK are you importing into - Online Tariff Duty calculator')
      end
    end
  end
end
