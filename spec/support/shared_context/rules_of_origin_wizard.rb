shared_context 'with rules of origin store' do |*traits, scheme_count: 1, scheme_traits: [], **store_attributes|
  before do
    allow(GeographicalArea).to receive(:find).with(wizardstore['country_code'])
                                             .and_return(country)

    allow(RulesOfOrigin::Scheme).to \
      receive(:for_heading_and_country).with(wizardstore['commodity_code'], wizardstore['country_code'])
                   .and_return(schemes)
  end

  let(:country) { build :geographical_area, :japan }

  let(:wizardstore) do
    build :rules_of_origin_wizard_store, *traits, schemes:,
                                                  country_code: country.id,
                                                  **store_attributes
  end

  let(:schemes) do
    shared_traits = traits & %i[subdivided other_subdivision]

    build_list :rules_of_origin_scheme,
               scheme_count,
               *(Array.wrap(scheme_traits) + shared_traits),
               countries: [country.id],
               articles:
  end

  let(:articles) { [] }
end

shared_context 'with rules of origin form step' do |step, *traits|
  subject { render_page && rendered }

  before do
    allow(view).to receive_messages(step_path: '/', return_to_commodity_path: '/')
  end

  include_context 'with rules of origin store', *traits

  let(:wizard) { RulesOfOrigin::Wizard.new wizardstore, step }
  let(:current_step) { wizard.find_current_step }

  let :render_page do
    render "rules_of_origin/steps/#{current_step.key}", current_step:, wizard:
  end
end

shared_examples_for 'an article accessor' do |method_name, article|
  describe "##{method_name}" do
    subject { instance.public_send(method_name) }

    context 'with matching article' do
      let(:articles) { attributes_for_list :rules_of_origin_article, 1, article: }

      it { is_expected.to eql articles.first[:content] }
    end

    context 'without matching article' do
      let(:articles) { [] }

      it { is_expected.to be_nil }
    end
  end
end
