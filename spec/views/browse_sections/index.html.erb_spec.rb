require 'spec_helper'

RSpec.describe 'browse_sections/index.html.erb', type: :view do
  subject { render }

  before { assign :sections, sections }

  let(:sections) { build_list :section, 3 }

  describe 'header' do
    it { is_expected.to have_css 'header h1', text: 'Browse the tariff' }
  end

  describe 'intro paragraph' do
    it { is_expected.to have_css 'p', text: /contains 3 sections/ }
  end

  describe 'table' do
    it { is_expected.to have_css 'tbody tr', count: 3 }
    it { is_expected.to have_css 'tbody tr td', count: 9 }
  end
end
