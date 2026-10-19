RSpec.describe DutyCalculator::Steps::SuggestedVatController, :user_session do
  render_views

  let(:user_session) { build(:duty_calculator_user_session, :with_commodity_information, vat: 'VAT', vat_assumed:) }
  let(:vat_assumed) { true }

  describe 'GET #show' do
    subject(:response) { get :show }

    it { expect(response).to have_http_status(:ok) }
    it { expect(response.body).to include('Suggested VAT rate') }
    it { expect(response.body).to include('As you are not sure, we have applied the standard-rate for this estimate. The resulting rate is itemised in the final calculations so you can see the impact.') }
    it { expect(response.body).to include("href=\"#{confirm_path}\"") }
    it { expect(response.body).to include("href=\"#{vat_path}\"") }

    context 'when the trader chose a rate' do
      let(:vat_assumed) { false }

      it { expect(response).to redirect_to(vat_path) }
    end
  end
end
