require 'spec_helper'

RSpec.describe 'rules_of_origin/_scheme', type: :view do
  subject(:rendered_page) { render_page && rendered }

  let :render_page do
    render 'rules_of_origin/scheme', scheme:, commodity_code: '2203000100'
  end

  let(:scheme) { build :rules_of_origin_scheme }

  it { is_expected.to have_css 'h3', text: /#{scheme.title}/ }
  it { is_expected.to have_css 'table' }
  it { is_expected.to have_css 'table th', count: 2 }
  it { is_expected.to have_css 'table td', count: 2 }
end
