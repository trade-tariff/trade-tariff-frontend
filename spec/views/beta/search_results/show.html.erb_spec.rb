require 'spec_helper'

RSpec.describe 'beta/search_results/show', type: :view do
  subject { render }

  before { assign(:search_result, search_result) }

  context 'when there multiple headings' do
    let(:search_result) { build(:search_result, :multiple_headings_view) }

    it { is_expected.to render_template('beta/search_results/_with_hits') }
    it { is_expected.to render_template('beta/search_results/_multiple_headings_search_results') }
    it { is_expected.to render_template('beta/search_results/_sidebar') }

    context 'when there is an intercept message' do
      let(:search_result) { build(:search_result, :multiple_headings_view, :with_intercept_message) }

      it { is_expected.to have_css('div#intercept-message') }
    end

    context 'when there is no intercept message' do
      let(:search_result) { build(:search_result, :multiple_headings_view, :no_intercept_message) }

      it { is_expected.not_to have_css('div#intercept-message') }
    end
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
    let(:search_result) { build(:search_result, :no_guide) }

    it { is_expected.not_to render_template('search/_guide_section') }
  end

  context 'when there are hits' do
    let(:search_result) { build(:search_result) }

    it { is_expected.to render_template('beta/search_results/_with_hits') }
    it { is_expected.not_to render_template('beta/search_results/_no_hits') }

    context 'when there is an intercept message' do
      let(:search_result) { build(:search_result, :with_intercept_message) }

      it { is_expected.to have_css('div#intercept-message') }
    end

    context 'when there is no intercept message' do
      let(:search_result) { build(:search_result, :no_intercept_message) }

      it { is_expected.not_to have_css('div#intercept-message') }
    end
  end

  context 'when there are no hits' do
    let(:search_result) { build(:search_result, :no_hits) }

    it { is_expected.not_to render_template('beta/search_results/_with_hits') }
    it { is_expected.to render_template('beta/search_results/_no_hits') }

    context 'when there is an intercept message' do
      let(:search_result) { build(:search_result, :no_hits, :with_intercept_message) }

      it { is_expected.to have_css('div#intercept-message') }
    end

    context 'when there is no intercept message' do
      let(:search_result) { build(:search_result, :no_hits, :no_intercept_message) }

      it { is_expected.not_to have_css('div#intercept-message') }
    end
  end

  context 'when the spelling has been corrected' do
    let(:search_result) { build(:search_result, :spelling_corrected) }

    it { is_expected.to have_css('div#search-results-spelling') }
  end

  context 'when the spelling has not been corrected' do
    let(:search_result) { build(:search_result, :spelling_not_corrected) }

    it { is_expected.not_to have_css('div#search-results-spelling') }
  end
end
