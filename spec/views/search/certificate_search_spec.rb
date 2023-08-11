RSpec.describe 'search/certificate_search', type: :view, vcr: { cassette_name: 'search#certificate_search_form' } do
  subject { render }

  before do
    form.valid?
    assign :form, form
    assign :query, form.to_params
    assign :certificates, certificates
  end

  context 'when there are results and no errors' do
    let(:certificates) { build_list(:certificate, 1, certificate_type_code: '9', certificate_code: '99L') }
    let(:form) { build(:certificate_search_form) }

    it { is_expected.to have_css('article.search-results h1.govuk-heading-l', text: 'Certificate search results') }
    it { is_expected.to have_css('article.search-results', text: '999L') }
  end

  context 'when there no results' do
    let(:certificates) { [] }
    let(:form) { build(:certificate_search_form) }

    it { is_expected.to have_css('article.search-results h1.govuk-heading-l', text: 'There are no matching results') }
  end

  context 'when there are errors in the submitted form' do
    let(:certificates) { [] }
    let(:form) { build(:certificate_search_form, code: nil, description: nil) }

    it { is_expected.to match('There is a problem') }
  end
end
