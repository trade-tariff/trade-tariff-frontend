require 'spec_helper'

RSpec.describe GreenLanes::EligibilitiesController, type: :request do
  subject { make_request && response }

  before do
    allow(TradeTariffFrontend).to receive(:green_lanes_enabled?).and_return true
  end

  let(:valid_params) do
    {
      green_lanes_eligibility_form: {
        moving_goods_gb_to_ni: 'yes',
        free_circulation_in_uk: 'yes',
        end_consumers_in_uk: 'yes',
        ukims: 'yes',
      },
    }
  end

  let(:invalid_params) do
    {
      green_lanes_eligibility_form: {
        moving_goods_gb_to_ni: '',
        free_circulation_in_uk: '',
        end_consumers_in_uk: '',
        ukims: '',
      },
    }
  end

  describe 'GET #new' do
    let(:make_request) { get new_green_lanes_eligibility_path, params: { commodity_code: '12345' } }

    it 'assigns @commodity_code' do
      make_request

      expect(assigns(:commodity_code)).to eq('12345')
    end

    it { is_expected.to have_http_status :ok }
  end

  describe 'POST #create' do
    context 'with valid params' do
      let(:make_request) { post green_lanes_eligibility_path, params: valid_params }

      it 'redirects to the result path' do
        make_request

        expect(response).to redirect_to(new_green_lanes_eligibility_result_path(valid_params[:green_lanes_eligibility_form]))
      end
    end

    context 'with invalid params' do
      let(:make_request) { post green_lanes_eligibility_path, params: invalid_params }

      it 'renders the new template' do
        make_request

        expect(response).to render_template('new')
      end
    end
  end
end
