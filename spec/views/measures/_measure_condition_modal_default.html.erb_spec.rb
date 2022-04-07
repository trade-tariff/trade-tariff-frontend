require 'spec_helper'

RSpec.describe 'measures/_measure_condition_modal_default', type: :view do
  subject { render_page && rendered }

  let :render_page do
    render 'measures/measure_condition_modal_default',
           measure: MeasurePresenter.new(measure)
  end

  context 'with measure which universal waiver does not apply to' do
    let(:measure) { build :measure, :with_conditions }

    it { is_expected.to render_template('measures/_measure_from_to') }
    it { is_expected.not_to have_css '.universal-waiver-applies-panel' }
    it { is_expected.not_to have_css '.permutation-group' }
  end

  context 'with measure which universal waiver applies to' do
    let(:measure) { build :measure, :with_conditions, :universal_waiver }

    context 'with UK service' do
      include_context 'with UK service'

      it { is_expected.to render_template('measures/_measure_from_to') }
      it { is_expected.to have_css '.universal-waiver-applies-panel' }
    end

    context 'with XI service' do
      include_context 'with XI service'

      it { is_expected.to render_template('measures/_measure_from_to') }
      it { is_expected.not_to have_css '.universal-waiver-applies-panel' }
    end
  end

  context 'with permutations enabled' do
    let(:measure) { build :measure, :with_conditions, :with_permutations }

    it { is_expected.to have_css '.permutation-group', count: 1 }
  end

  context 'with multiple permutation groups' do
    let :measure do
      build :measure, measure_conditions: conditions,
                      measure_condition_permutation_groups: groups
    end

    let(:conditions) { attributes_for_pair :measure_condition }

    let :groups do
      conditions.map do |measure_condition|
        attributes_for :measure_condition_permutation_group,
                       measure_conditions: [measure_condition]
      end
    end

    it { is_expected.to have_css '.permutation-group', count: 2 }
  end
end
