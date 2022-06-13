require 'spec_helper'

RSpec.describe 'rules_of_origin/steps/_sidebar', type: :view do
  include_context 'with rules of origin form step', 'originating', :importing

  let :render_page do
    render 'rules_of_origin/steps/sidebar', current_step:, wizard:
  end

  it { is_expected.to have_css '[data-controller="step-by-step-nav"]' }
  it { is_expected.to have_css '.app-step-nav ol.app-step-nav__steps' }
  it { is_expected.to have_css '.app-step-nav ol li' }
end
