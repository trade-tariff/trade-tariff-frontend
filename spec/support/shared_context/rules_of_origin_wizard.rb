shared_context 'with rules of origin store' do |state|
  before do
    allow(GeographicalArea).to receive(:find).with(wizardstore['country_code'])
                                             .and_return(country)

    allow(RulesOfOrigin::Scheme).to \
      receive(:all).with(wizardstore['commodity_code'], wizardstore['country_code'])
                   .and_return(schemes)
  end

  let(:wizardstore) do
    build :rules_of_origin_wizard_store, state, schemes:, country_code: country.id
  end

  let(:country) { build :geographical_area, :japan }
  let(:schemes) { build_list :rules_of_origin_scheme, 1, countries: [country.id] }
end

shared_context 'with rules of origin form step' do |step, state|
  subject { render_page && rendered }

  include_context 'with rules of origin store', state
  include_context 'with govuk form builder'

  let(:wizard) { RulesOfOrigin::Wizard.new wizardstore, step }
  let(:current_step) { wizard.find_current_step }

  let :render_page do
    view.form_for current_step, url: '/' do |form|
      render "rules_of_origin/steps/#{current_step.key}", form:, wizard:
    end
  end
end
