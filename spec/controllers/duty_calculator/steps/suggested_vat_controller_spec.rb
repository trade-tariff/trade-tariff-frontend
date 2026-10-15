RSpec.describe DutyCalculator::Steps::SuggestedVatController, :user_session do
  render_views

  let(:user_session) { build(:duty_calculator_user_session, :with_commodity_information, vat: 'VAT', vat_assumed:) }
  let(:vat_assumed) { true }

  describe 'GET #show' do
    subject(:response) { get :show }

    it { expect(response).to have_http_status(:ok) }
    it { expect(response.body).to include('Suggested VAT rate') }
    it { expect(response.body).to include('If you cannot provide details, generally standard-rate VAT (20%) applies.') }
    it { expect(response.body).to include("href=\"#{confirm_path}\"") }
    it { expect(response.body).to include("href=\"#{vat_path}\"") }

    context 'when the trader chose a rate' do
      let(:vat_assumed) { false }

      it { expect(response).to redirect_to(vat_path) }
    end
  end
end
