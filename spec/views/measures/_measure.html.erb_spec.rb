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

    render 'measures/measure', measure: MeasurePresenter.new(measure)
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

  context 'with residual measure' do
    let(:measure) { build(:measure, :residual) }

    it { expect(rendered).to match(/Control does not apply to goods/) }

    it { expect(rendered).to match(measure.additional_code.code) }

    it { expect(rendered).to match(measure.additional_code.formatted_description) }
  end
end
