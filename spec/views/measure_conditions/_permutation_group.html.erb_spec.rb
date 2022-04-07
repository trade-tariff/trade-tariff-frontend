require 'spec_helper'

RSpec.describe 'measure_conditions/permutation_group', type: :view do
  subject { render_page && rendered }

  let :render_page do
    render 'measure_conditions/permutation_group',
           permutation_group: permutation_group
  end

  let(:permutation_group) { build :measure_condition_permutation_group }

  it { is_expected.to have_css '.permutation-group' }
  it { is_expected.to have_css '.permutation-group table thead tr' }
  it { is_expected.to have_css '.permutation-group table tbody tr', count: 1 }
  it { is_expected.to have_css '.permutation-group > p', text: /Meet the following condition/ }

  context 'with multiple permutations' do
    let :permutation_group do
      build :measure_condition_permutation_group,
            permutations: attributes_for_pair(:measure_condition_permutation)
    end

    it { is_expected.to have_css '.permutation-group table tbody tr', count: 2 }
    it { is_expected.to have_css '.permutation-group > p', text: /Meet one of the following/ }
  end
end
