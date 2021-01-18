require 'spec_helper'

describe 'measures/_measure.html.erb', type: :view do
  let(:measure) do
    Measure.new(
      attributes_for(:measure, :third_country,
                     duty_expression: duty_expression).stringify_keys,
    )
  end

  before do
    render 'measures/measure.html.erb', measure: MeasurePresenter.new(measure)
  end

  context 'with formatted_base' do
    let(:duty_expression) { attributes_for(:duty_expression).stringify_keys }

    it {
      expect(rendered).to match(/EUR/)
      expect(rendered).to match(/Hectokilogram/)
      expect(rendered).to match(/<abbr title='Hectokilogram'>/)
    }
  end

  context 'without formatted_base' do
    let(:duty_expression) do
      attributes_for(:duty_expression, formatted_base: nil).stringify_keys
    end

    it {
      expect(rendered).to match(/EUR/)
      expect(rendered).to match(/Hectokilogram/)
    }
  end
end
