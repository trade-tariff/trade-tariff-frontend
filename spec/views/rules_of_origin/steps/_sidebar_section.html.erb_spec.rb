require 'spec_helper'

RSpec.describe 'rules_of_origin/steps/_sidebar_section', type: :view do
  include_context 'with rules of origin form step', 'import_export'

  let(:sections) { wizard.sections.index_by(&:name) }

  let :render_page do
    render 'rules_of_origin/steps/sidebar_section',
           sidebar_section: sections['originating'],
           sidebar_section_counter: 1,
           current_step:
  end

  let(:commcode) { wizardstore['commodity_code'] }

  it { is_expected.to have_css 'li.app-step-nav__step h3.app-step-nav__title span', text: 'Step 2' }
  it { is_expected.to have_css 'li h3 span', text: "Are your goods 'originating'?" }

  it { is_expected.to have_css 'li .app-step-nav__panel ol li' }
  it { is_expected.not_to have_css 'li.app-step-nav.app-step-nav__step--active' }
  it { is_expected.not_to have_css 'li ol li.app-step-nav__list-item--active' }

  context 'when rendering current_step' do
    let :render_page do
      render 'rules_of_origin/steps/sidebar_section', object: sections['originating'],
                                                      sidebar_section_counter: 1,
                                                      current_step:

      it { is_expected.to have_css 'li.app-step-nav.app-step-nav__step--active' }
      it { is_expected.to have_css 'li ol li.app-step-nav__list-item--active' }
    end
  end

  context 'when addition info available' do
    let :render_page do
      render 'rules_of_origin/steps/sidebar_section',
             sidebar_section: sections['details'],
             sidebar_section_counter: 1,
             current_step:
    end

    it { is_expected.to have_css '.app-step-nav__panel > p', text: /commodity #{commcode} into the UK from #{country.description}/m }
    it { is_expected.to have_link commcode.to_s }
  end
end
