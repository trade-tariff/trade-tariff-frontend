require 'spec_helper'

RSpec.describe 'measure_conditions/permutation', type: :view do
  subject { render_page && rendered }

  let :render_page do
    render 'measure_conditions/permutation', permutation: permutation
  end

  let :permutation do
    build :measure_condition_permutation, measure_conditions: conditions
  end

  let(:conditions) { [condition] }
  let(:condition) { attributes_for :measure_condition }

  it { is_expected.to have_css 'tr td', count: 3 }
  it { is_expected.to have_css 'tr td:nth-of-type(1)', text: Regexp.new(condition[:document_code]) }
  it { is_expected.to have_css 'tr td:nth-of-type(2)', text: Regexp.new(condition[:requirement]) }
  it { is_expected.to have_css 'tr td:nth-of-type(3)', text: Regexp.new(condition[:action]) }
  it { is_expected.to have_css 'tr td:nth-of-type(3)', text: Regexp.new(condition[:duty_expression]) }
  it { is_expected.to have_css 'tr td:nth-of-type(3) br', count: 1 }

  context 'with multiple conditions in permutation' do
    let(:conditions) { attributes_for_pair :measure_condition }

    it { is_expected.to have_css 'tr td', count: 3 }
    it { is_expected.to have_css 'tr td:nth-of-type(1)', text: ' + ' }
    it { is_expected.to have_css 'tr td:nth-of-type(2) p', text: 'and' }
    it { is_expected.to have_css 'tr td:nth-of-type(3) br', count: 1 }
  end
end
