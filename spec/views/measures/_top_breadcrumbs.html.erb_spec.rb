require 'spec_helper'

RSpec.describe 'shared/_top_breadcrumbs', type: :view do
  subject { render }

  let(:section) { build :section }
  let(:chapter) { build :chapter }
  let(:heading) { build :heading }
  let(:commodity) { build :commodity }

  before do
    assign(:section, section)
    assign(:chapter, chapter)
    assign(:heading, heading)
    assign(:commodity, commodity)
  end

  it { is_expected.to have_content 'Section' }
  it { is_expected.to have_content 'Chapter' }

  context 'when heading is declarable' do
    let(:heading) { build :heading, declarable: true }

    it { is_expected.not_to have_content 'Heading' }
    it { is_expected.to have_content 'Commodity' }
  end

  context 'when heading is NOT declarable' do
    let(:heading) { build :heading, declarable: false }

    it { is_expected.to have_content 'Heading' }
    it { is_expected.to have_content 'Commodity' }
  end
end
