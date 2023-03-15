require 'spec_helper'

RSpec.describe MeasureComponent do
  describe '#unit_for_classification' do
    subject(:component) do
      build(
        :measure,
        :with_supplementary_measure_components,
        duty_expression: attributes_for(:duty_expression, :supplementary),
      ).measure_components.first
    end

    it { expect(component.unit_for_classification).to eq('Number of items (p/st)') }
  end
end
