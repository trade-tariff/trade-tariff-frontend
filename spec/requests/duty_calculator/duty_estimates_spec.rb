require 'spec_helper'

RSpec.describe 'Duty calculator result content', :user_session, type: :request do
  include_context 'with UK service'

  let(:user_session) do
    build(
      :duty_calculator_user_session,
      commodity_code: '0103921100',
      import_date: '2026-09-01',
      import_destination: 'UK',
      country_of_origin: 'AR',
      customs_value: { 'monetary_value' => '10000', 'shipping_cost' => '180', 'insurance_cost' => '20' },
      vat: 'VAT',
    )
  end
  let(:rows) do
    [
      ['Valuation for import', 'Value of goods + freight + insurance costs', '£10,200.00'],
      ['Import duty', '0.00% * £10,200.00', '£0.00'],
      ['VAT', '20.00% * £10,200.00', '£2,040.00'],
      ['Duty Total', nil, '£2,040.00'],
    ]
  end
  let(:standard_option) do
    values = [
      ['Valuation for import', 'Value of goods + freight + insurance costs', '£10,200.00'],
      ['Import duty', '12.00% * £10,200.00', '£1,224.00'],
      ['VAT', '20.00% * £11,424.00', '£2,284.80'],
      ['Duty Total', nil, '£3,508.80'],
    ]
    build(:duty_calculator_duty_option_result, values:).tap { |option| option.duty_and_vat_total = 3508.80 }
  end
  let(:option_attributes) do
    { category: :tariff_preference, type: 'tariff_preference', measure_type_id: '142', geographical_area_description: 'Argentina' }
  end
  let(:reduced_option) do
    build(:duty_calculator_duty_option_result, **option_attributes, values: rows).tap do |option|
      option.duty_and_vat_total = 2040
      option.footnote_suffix = '<p class="govuk-body">Northern Ireland explanation</p>'.html_safe
    end
  end
  let(:duty_options) { [standard_option, reduced_option] }
  let(:page) do
    get duty_path
    Nokogiri::HTML(response.body)
  end
  let(:result_section) { page.css('section').last }

  before do
    allow(DutyCalculator::DutyCalculator).to receive(:new)
      .and_return(instance_double(DutyCalculator::DutyCalculator, options: duty_options))
    allow(DutyCalculator::Api::GeographicalArea).to receive(:build)
      .with(:uk, 'AR')
      .and_return(DutyCalculator::Api::GeographicalArea.new(geographical_area_id: 'AR', description: 'Argentina'))
  end

  it 'groups the available reduced rates', :aggregate_failures do
    expect(page.css('[data-analytics-exposure-event-value="duty_calculator_completed"] h2').map(&:text)).to eq(['Estimated duty and VAT using standard duty', 'Available reduced duty rates', 'Details used for this estimate'])
    expect(result_section.at_css('h3').text).to eq('Tariff preference - Argentina')
    expect(result_section.at_css('h4').text).to eq('Tariff preference - Argentina')
  end

  it 'shows the country preference copy' do
    expect(result_section.text).to include('A reduced tariff preference rate is available if you can prove the origin of your goods.')
  end

  it 'keeps the total including VAT' do
    expect(result_section.at_css('.duty-estimate__amount').text).to eq('£2,040.00')
  end

  it 'keeps the Northern Ireland explanation' do
    expect(result_section.text.scan('Northern Ireland explanation').size).to eq(1)
  end

  it 'links to rules of origin' do
    expect(result_section.css('a').map { |link| link['href'] }).to include('/howto/origin')
  end

  [
    ['CPTPP all members', '2051', 'cptpp', 'CPTPP All Members', 'Comprehensive and Progressive Agreement for Trans-Pacific Partnership (CPTPP)'],
    ['CPTPP member', '2052', 'japan', 'CPTPP Japan', 'Comprehensive and Progressive Agreement for Trans-Pacific Partnership (CPTPP)'],
    ['DCTS comprehensive', '1062', nil, 'Developing Countries Trading Scheme (DCTS) - Comprehensive Preferences', 'Developing Countries Trading Scheme (DCTS)'],
    ['DCTS enhanced', '1061', nil, 'Developing Countries Trading Scheme (DCTS) - Enhanced Preferences', 'Developing Countries Trading Scheme (DCTS)'],
    ['DCTS standard', '1060', nil, 'Developing Countries Trading Scheme (DCTS) - Standard Preferences', 'Developing Countries Trading Scheme (DCTS)'],
  ].each do |label, geographical_area_id, scheme_code, area, scheme_name|
    context "when the preference is #{label}" do
      let(:option_attributes) { super().merge(geographical_area_id:, scheme_code:, geographical_area_description: area) }

      it 'shows the scheme introduction' do
        expect(result_section.text).to include("A reduced tariff preference rate is available if goods are declared under the #{scheme_name}.")
      end
    end
  end

  [
    ['autonomous', '112', 'Autonomous tariff suspension', 'if the preference code is added to the customs declaration.', 'You’ll need to claim this on your declaration.'],
    ['certain_category_goods', '117', 'Shipping tariff suspension', 'for drilling or production platforms.', 'the relevant end-use authorisation number.'],
    ['airworthiness', '119', 'Airworthiness tariff suspension', 'To claim this suspension you will need to provide an Authorised Release Certificate.', 'and have an Authorised Release Certificate.'],
    ['autonomous_end_use', '115', 'Autonomous suspension under end use', 'is accompanied by the relevant authorisation document.', 'and have the relevant authorisation document.'],
  ].each do |type, measure_type_id, name, introduction, explanation|
    context "when the suspension is #{type}" do
      let(:option_attributes) { { category: :suspension, type:, measure_type_id: } }

      it 'shows the suspension copy', :aggregate_failures do
        expect(result_section.at_css('h3').text).to eq(name)
        expect(result_section.xpath('./p').map(&:text).join(' ')).to include(introduction)
        expect(result_section.at_css('details').text).to include(explanation)
      end
    end
  end

  [
    ['non_preferential', '122', 'Non-preferential quota', 'under a non-preferential quota if the preference code is added to the customs declaration.'],
    ['non_preferential_end_use', '123', 'Non-preferential quota under end use', 'and you have the relevant end-use authorisation.'],
    ['preferential', '143', 'Preferential tariff quota', 'under a preferential quota if the preference code is added to the customs declaration.'],
  ].each do |type, measure_type_id, name, introduction|
    context "when the quota is #{type}" do
      let(:option_attributes) { { category: :quota, type:, measure_type_id:, order_number: '059741' } }

      it 'shows the quota copy and number', :aggregate_failures do
        expect(result_section.at_css('h3').text).to eq("#{name} 059741")
        expect(result_section.css('p').first.text).to include(introduction)
        expect(result_section.at_css('details').text).to include('Quotas are where a specified amount of a good can enter the country at a reduced duty rate.')
        expect(result_section.css('a').map { |link| link['href'] }).to include('/howto/quotas')
      end
    end
  end

  context 'when preference requires authorised use' do
    let(:option_attributes) { super().merge(measure_type_id: '145') }

    it 'shows the authorised use copy', :aggregate_failures do
      expect(result_section.at_css('h3').text).to eq('Preference under authorised use')
      expect(result_section.css('p').first.text).to eq('A reduced duty rate is available if you can prove the origin of the goods.')
      expect(result_section.at_css('details').text).to include('you will need to provide evidence of compliance with your shipment.')
    end
  end

  context 'when non-preference requires authorised use' do
    let(:option_attributes) { { category: :third_country_tariff, type: 'third_country_tariff', measure_type_id: '105' } }

    it 'does not describe it as standard duty', :aggregate_failures do
      expect(result_section.at_css('h3').text).to eq('Non-preferential authorised use')
      expect(result_section.css('p').first.text).to eq('A reduced duty rate is available if the goods are going to be processed or put to a specific use.')
      expect(result_section.at_css('details').text).to include('In order to benefit from this you have to first be authorised.')
      expect(result_section.text).not_to include('This is the default rate')
    end
  end

  context 'when only standard duty applies' do
    let(:duty_options) { [standard_option] }

    it 'does not offer reduced rates' do
      expect(page.text).not_to include('Available reduced duty rates')
    end
  end

  context 'when an option has no revised copy' do
    let(:option_attributes) { { category: :suspension, type: 'preferential', measure_type_id: '141', footnote: '<p>Existing suspension explanation</p>' } }

    it 'keeps the existing explanation' do
      expect(result_section.at_css('details').text).to include('Existing suspension explanation', 'Northern Ireland explanation')
    end
  end

  context 'when calculations are unavailable' do
    let(:rows) { [] }

    it 'keeps the explanation without a disclosure', :aggregate_failures do
      expect(result_section.at_css('details')).to be_nil
      expect(result_section.text).to include('To claim this rate you must be able to provide proof of origin.', 'Northern Ireland explanation')
    end
  end
end
