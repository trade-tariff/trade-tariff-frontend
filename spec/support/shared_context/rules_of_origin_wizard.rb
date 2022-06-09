shared_context 'with rules of origin store' do |*traits, scheme_count: 1, **store_attributes|
  before do
    allow(GeographicalArea).to receive(:find).with(wizardstore['country_code'])
                                             .and_return(country)

    allow(RulesOfOrigin::Scheme).to \
      receive(:all).with(wizardstore['commodity_code'], wizardstore['country_code'])
                   .and_return(schemes)
  end

  let(:country) { build :geographical_area, :japan }

  let(:wizardstore) do
    build :rules_of_origin_wizard_store, *traits, schemes:,
                                                  country_code: country.id,
                                                  **store_attributes
  end

  let(:schemes) do
    build_list :rules_of_origin_scheme, scheme_count, countries: [country.id]
  end
end

shared_context 'with rules of origin form step' do |step, *traits|
  subject { render_page && rendered }

  before { allow(view).to receive(:step_path).and_return '/' }

  include_context 'with rules of origin store', *traits

  let(:wizard) { RulesOfOrigin::Wizard.new wizardstore, step }
  let(:current_step) { wizard.find_current_step }

  let :render_page do
    render "rules_of_origin/steps/#{current_step.key}", current_step:, wizard:
  end
end
