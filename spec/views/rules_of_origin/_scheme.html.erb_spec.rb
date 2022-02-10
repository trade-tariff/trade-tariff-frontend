require 'spec_helper'

RSpec.describe 'rules_of_origin/_scheme', type: :view do
  subject(:rendered_page) { render_page && rendered }

  let(:country_name) { 'Kenya' }
  let(:commodity_code) { '0302111000' }
  let(:multiple_schemes) { true }
  let(:scheme) { build :rules_of_origin_scheme }

  let :render_page do
    render 'rules_of_origin/scheme', scheme: scheme,
                                     country_name: country_name,
                                     commodity_code: commodity_code,
                                     multiple_schemes: multiple_schemes
  end

  it 'includes comm code' do
    expect(rendered_page).to have_css '.rules-of-origin__scheme h3',
                                      text: /rules for commodity 0302111000/
  end

  describe 'scheme caption' do
    context 'with single scheme' do
      let(:multiple_schemes) { false }

      it { is_expected.not_to have_css 'h3 span' }
    end

    context 'with multiple schemes' do
      it { is_expected.to have_css 'h3 span' }
    end
  end

  it { is_expected.to have_css 'table.commodity-rules-of-origin' }
  it { is_expected.not_to have_css 'p', text: /no product-specific rules/ }

  it 'includes the introductory_notes section' do
    expect(rendered_page).to have_css 'details .tariff-markdown p',
                                      text: /Details of introductory notes/
  end

  context 'with no rules' do
    let(:scheme) { build :rules_of_origin_scheme, rule_count: 0 }

    it { is_expected.not_to have_css 'table.commodity-rules-of-origin' }
    it { is_expected.not_to have_css 'details.govuk-details' }
    it { is_expected.to have_css 'p', text: /no product-specific rules/ }
  end
end
