require 'spec_helper'

RSpec.describe 'rules_of_origin/steps/_proof_requirements', type: :view do
  include_context 'with rules of origin form step',
                  'proof_requirements',
                  :wholly_obtained

  let :articles do
    attributes_for_list :rules_of_origin_article, 1, article: 'origin_processes',
                                                     content:
  end

  let(:content) { "## First section\n\nfirst\n\n## Second section\n\nsecond\n" }

  it { is_expected.to have_css 'span.govuk-caption-xl', text: /obtaining and verifying/i }
  it { is_expected.to have_css 'h1', text: /Requirements.*Japan/ }
  it { is_expected.to have_css 'p', text: %r{processes.*#{schemes.first.title}} }
  it { is_expected.to have_css '.tariff-markdown *' }
  it { is_expected.to have_css '#article-section-list li a', count: 2 }
  it { is_expected.to have_link 'First section' }
  it { is_expected.to have_link 'Second section' }
  it { is_expected.to have_css '#article-section h2', count: 1, text: 'First section' }

  context 'with second section chosen' do
    let :render_page do
      render "rules_of_origin/steps/#{current_step.key}", current_step:,
                                                          wizard:,
                                                          params: { section: 2 }
    end

    it { is_expected.to have_css '#article-section-list li a', count: 2 }
    it { is_expected.to have_link 'First section' }
    it { is_expected.to have_link 'Second section' }
    it { is_expected.to have_css '#article-section h2', count: 1, text: 'Second section' }
  end
end
