require 'spec_helper'

RSpec.describe 'beta/search_results/show', type: :view do
  subject { render }

  before { assign(:search_result, search_result) }

  context 'when there multiple headings' do
    let(:search_result) { build(:search_result, :multiple_headings_view) }

    it { is_expected.to render_template('beta/search_results/_multiple_headings_search_results') }
    it { is_expected.to render_template('beta/search_results/_sidebar') }
  end

  context 'when there are not multiple headings' do
    let(:search_result) { build(:search_result) }

    it { is_expected.to render_template('beta/search_results/_search_results') }
    it { is_expected.to render_template('beta/search_results/_sidebar') }
  end

  context 'when there are no facet statistics' do
    let(:search_result) { build(:search_result, :no_facets) }

    it { is_expected.to render_template('beta/search_results/_search_results') }
    it { is_expected.not_to render_template('beta/search_results/_sidebar') }
  end

  context 'when guide exists' do
    let(:search_result) { build(:search_result) }

    it { is_expected.to render_template('search/_guide_section') }
  end

  context "when guide doesn't exist" do
    let(:search_result) { build(:search_result) }

    before do
      search_result.guide = nil
    end

    it { is_expected.not_to render_template('search/_guide_section') }
  end
end
