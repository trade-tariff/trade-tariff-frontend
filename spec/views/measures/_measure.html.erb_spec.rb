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

  context 'with formatted_base' do
    let(:duty_expression) { attributes_for(:duty_expression) }

    it { expect(rendered).to match(/EUR/) }
    it { expect(rendered).to match(/Hectokilogram/) }
    it { expect(rendered).to match(/<abbr title="Hectokilogram">/) }
  end

  context 'without formatted_base' do
    let(:duty_expression) do
      attributes_for(:duty_expression, formatted_base: nil)
    end

    it { expect(rendered).to match(/EUR/) }
    it { expect(rendered).to match(/Hectokilogram/) }
  end
end
