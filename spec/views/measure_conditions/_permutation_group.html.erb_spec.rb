require 'spec_helper'

RSpec.describe 'measure_conditions/permutation_group', type: :view do
  subject { render_page && rendered }

  let :render_page do
    render 'measure_conditions/permutation_group',
           permutation_group: group
  end

  let(:group) { build :measure_condition_permutation_group, condition_count: 2 }

  it { is_expected.to have_css '.permutation-group' }
  it { is_expected.to have_css '.permutation-group > table thead tr' }
  it { is_expected.to have_css '.permutation-group > table tbody tr', count: 1 }
  it { is_expected.to have_css '.permutation-group > p', text: /Meet the following condition/ }
  it { is_expected.to have_css '.permutation-group > details', count: 1 }
  it { is_expected.to have_css '.permutation-group > details tbody tr', count: 2 }

  context 'with multiple permutations' do
    let :group do
      build :measure_condition_permutation_group, permutation_count: 2,
                                                  condition_count: 2
    end

    it { is_expected.to have_css '.permutation-group > table tbody tr', count: 2 }
    it { is_expected.to have_css '.permutation-group > p', text: /Meet one of the following/ }
    it { is_expected.to have_css '.permutation-group > details', count: 1 }
    it { is_expected.to have_css '.permutation-group > details tbody tr', count: 4 }
  end

  context 'with permutations with repeated conditions' do
    let :group do
      build :measure_condition_permutation_group,
            permutations: [
              attributes_for(:measure_condition_permutation,
                             measure_conditions: [shared, first]),
              attributes_for(:measure_condition_permutation,
                             measure_conditions: [shared, second]),
            ]
    end

    let(:shared) { attributes_for :measure_condition, :with_guidance }
    let(:first)  { attributes_for :measure_condition, :with_guidance }
    let(:second) { attributes_for :measure_condition, :with_guidance }

    it { is_expected.to have_css '.permutation-group > details', count: 1 }
    it { is_expected.to have_css '.permutation-group > details tbody tr', count: 3 }
  end
end
