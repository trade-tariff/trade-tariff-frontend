require 'spec_helper'

RSpec.describe 'rules_of_origin/steps/_rules_not_met', type: :view do
  include_context 'with rules of origin form step',
                  'rules_not_met',
                  :insufficient_processing

  let :articles do
    attributes_for_list :rules_of_origin_article, 1,
                        article: 'tolerances'
  end

  it { is_expected.to have_css 'span.govuk-caption-xl', text: %r{(Im|Ex)porting.* #{wizardstore['commodity_code']}.*Japan.*UK} }
  it { is_expected.to have_css 'h1', text: /not met/i }
  it { is_expected.to have_css '.rules-of-origin-met-message', text: %r{#{schemes.first.title}} }
  it { is_expected.to have_css '.tariff-markdown', text: %r{#{schemes.first.title}} }
  it { is_expected.to have_css '#tolerances-section p a' }
  it { is_expected.to have_css '#sets-section h3' }
  it { is_expected.to have_css '#sets-section p' }
  it { is_expected.to have_css '#sets-section details' }
  it { is_expected.to have_css '#cumulation-section h3' }
  it { is_expected.to have_css '#cumulation-section a' }
  it { is_expected.to have_css '#whats-next-section.panel--coloured strong' }
  it { is_expected.to have_css '#whats-next-section a', count: 2 }
  it { is_expected.to have_link 'feedback' }
  it { is_expected.not_to have_css '#next-steps' }

  context 'without tolerances article' do
    let(:articles) { [] }

    it { is_expected.not_to have_css '#tolerances-section' }
  end

  context 'when not passed through cumulation page' do
    before { allow(current_step).to receive(:show_cumulation_section?).and_return false }

    it { is_expected.not_to have_css '#cumulation-section h3' }
    it { is_expected.not_to have_css '#cumulation-section a' }
  end
end
