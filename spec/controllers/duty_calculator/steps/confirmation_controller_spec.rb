RSpec.describe DutyCalculator::Steps::ConfirmationController, :user_session do
  let(:user_session) do
    build(
      :duty_calculator_user_session,
      :with_commodity_information,
      :with_import_date,
      :with_import_destination,
      :with_country_of_origin,
      :without_trader_scheme,
      :with_small_turnover,
      :with_planned_processing,
      :with_certificate_of_origin,
      :with_meursing_additional_code,
      :with_customs_value,
      :with_measure_amount,
      :with_vat,
    )
  end

  describe 'GET #show' do
    render_views

    subject(:response) { get :show }

    let(:expected_links) do
      [
        '/sections',
        '/duty-calculator/0702000007/import-date',
        '/duty-calculator/import-destination',
        '/duty-calculator/country-of-origin',
        '/duty-calculator/trader-scheme',
        '/duty-calculator/certificate-of-origin',
        '/duty-calculator/meursing-additional-codes',
        '/duty-calculator/customs-value',
        '/duty-calculator/measure-amount',
        '/duty-calculator/vat',
      ]
    end

    it 'assigns the correct decorated_step' do
      response
      expect(assigns[:decorated_step]).to be_a(DutyCalculator::ConfirmationDecorator)
    end

    it { expected_links.each { |link| expect(response.body).to include(link) } }
    it { expect(response).to have_http_status(:ok) }
    it { expect(response).to render_template('confirmation/show') }
  end

  context 'when the duty calculator UX improvements are switched on' do
    render_views

    subject(:response) { get :show }

    let(:user_session) do
      build(
        :duty_calculator_user_session,
        :with_commodity_information,
        import_date: '2026-09-01',
        import_destination: 'UK',
        country_of_origin: 'AR',
        customs_value: { 'monetary_value' => '10000', 'shipping_cost' => '180.5', 'insurance_cost' => '' },
        vat: 'VAT',
        vat_assumed:,
      )
    end
    let(:vat_assumed) { false }

    before do
      allow(TradeTariffFrontend).to receive(:duty_calculator_ux_improvements?).and_return(true)
      allow(DutyCalculator::Api::GeographicalArea).to receive(:build)
        .with(:uk, 'AR')
        .and_return(DutyCalculator::Api::GeographicalArea.new(geographical_area_id: 'AR', description: 'Argentina'))
    end

    it { expect(response.body).to include('Tell us about this import') }
    it { expect(response.body).to include('England, Scotland or Wales (GB)') }
    it { expect(response.body).to include('Argentina (AR)') }
    it { expect(response.body).to include('1 September 2026') }
    it { expect(response.body).to include('What did you pay for the goods and delivery?') }
    it { expect(response.body).to include('£10,000') }
    it { expect(response.body).to include('£180.50') }
    it { expect(response.body).to include('£0.00') }
    it { expect(response.body).to include('Standard rate VAT (20%)') }
    it { expect(response.body).not_to include('generally standard-rate VAT') }
    it { expect(response.body).to include('href="/duty-calculator/0702000007/import-details"') }
    it { expect(response.body).to include('href="/duty-calculator/customs-value"') }
    it { expect(response.body).to include('href="/duty-calculator/vat"') }
    it { expect(response.body).to include('VAT rate</span>') }
    it { expect(response.body).to include('href="/duty-calculator/duty"') }
    it { expect { response }.to change(user_session, :return_to_confirm).from(nil).to(true) }

    context 'when the commodity has only one VAT rate' do
      let(:user_session) do
        build(:duty_calculator_user_session, :with_commodity_information, import_date: '2026-09-01', import_destination: 'UK', country_of_origin: 'AR', vat: nil)
      end

      before do
        allow(DutyCalculator::ConfirmationDecorator).to receive(:new).and_wrap_original do |original, *args|
          original.call(*args).tap do |decorator|
            allow(decorator).to receive(:applicable_vat_options).and_return('VATR' => 'VAT reduced rate 5%')
          end
        end
      end

      it { expect(response.body).to include('Reduced rate VAT (5%)') }
      it { expect(response.body).not_to include('VAT rate</span>') }
    end

    context 'when answers are missing' do
      let(:user_session) { build(:duty_calculator_user_session, :with_commodity_information) }

      it { expect(response).to have_http_status(:ok) }
      it { expect(response.body).not_to include('Tell us about this import') }
      it { expect(response.body).not_to include('What did you pay for the goods and delivery?') }
    end

    context 'when the VAT rate was assumed' do
      let(:vat_assumed) { true }

      it { expect(response.body).to include('If you cannot provide details, generally standard-rate VAT (20%) applies.') }
      it { expect(response.body).to include('href="/duty-calculator/suggested-vat"') }
    end
  end
end
