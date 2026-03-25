require 'spec_helper'

RSpec.describe 'measures/_measure', type: :view, vcr: { cassette_name: 'geographical_areas#1013' } do
  let(:measure) do
    Measure.new(
      attributes_for(:measure, :third_country,
                     duty_expression:),
    )
  end

  before do
    stub_const('MeasureConditionDialog::CONFIG_FILE_NAME', file_fixture('measure_condition_dialog_config.yaml'))

    render 'measures/measure', measure: MeasurePresenter.new(measure), roo_schemes: []
  end

  context 'with verbose_duty' do
    let(:duty_expression) { attributes_for(:duty_expression) }

    it { expect(rendered).to match(/drained net weight/) }
    it { expect(rendered).to match(/£7.80/) }
    it { expect(rendered).to match(/100 kg/) }
  end

  context 'without verbose_duty' do
    let(:duty_expression) do
      attributes_for(:duty_expression, verbose_duty: nil)
    end

    it { expect(rendered).to match(/EUR/) }
    it { expect(rendered).to match(/Hectokilogram/) }
  end

  context 'when rendering a UK geographical area link override on the XI service' do
    let(:measure) do
      build(
        :measure,
        :eu,
        geographical_area: attributes_for(:geographical_area, id: '1013', geographical_area_id: '1013', description: 'European Union', child_area_ids: %w[FR DE]),
      )
    end

    before do
      TradeTariffFrontend::ServiceChooser.with_source(:xi) do
        render 'measures/measure',
               measure: MeasurePresenter.new(measure),
               roo_schemes: [],
               geographical_area_link_service: :uk
      end
    end

    it 'links to the UK geographical area page' do
      href = Capybara.string(rendered).find('td.country-col a.govuk-link', text: 'European Union', match: :first).native['href']

      expect(href).to eq('/geographical_areas/1013')
    end
  end

  context 'with a prohibitive measure that has an additional code' do
    let(:measure) { build(:measure, :prohibitive, :with_additional_code) }

    it { expect(rendered).to render_template('measures/additional_codes/_prohibitive') }
  end

  context 'with a non-prohibitive measure that has an additional code' do
    let(:measure) { build(:measure, :with_additional_code) }

    it { expect(rendered).to render_template('measures/additional_codes/_regular') }
  end

  context 'when standard rate' do
    context 'with a VAT measure that has no additional code' do
      let(:measure) { build(:measure, :vat) }

      it { expect(rendered).to match(/Standard rate/) }
    end

    context 'without a VAT measure' do
      let(:measure) { build(:measure) }

      it { expect(rendered).not_to match(/Standard rate/) }
    end
  end
end
