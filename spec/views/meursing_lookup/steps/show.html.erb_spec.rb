require 'spec_helper'

RSpec.describe 'meursing_lookup/steps/show', type: :view do
  before do
    allow(view).to receive(:current_step).and_return(current_step)
    allow(view).to receive(:wizard).and_return(wizard)
    allow(view).to receive(:last_commodity_code).and_return('')

    allow(current_step).to receive(:options).and_return([])

    render
  end

  let(:wizard) { MeursingLookup::Wizard.new(store, 'end') }
  let(:store) { WizardSteps::Store.new(input_answers) }

  let(:input_answers) do
    {
      'starch' => '0 - 4.99',
      'sucrose' => '0 - 4.99',
      'milk_fat' => '0 - 1.49',
      'milk_protein' => '0 - 2.49',
    }
  end

  shared_examples 'an answer step view' do |step_class|
    let(:current_step) { step_class.new(wizard, store) }

    it { expect(rendered).to render_template('meursing_lookup/steps/show') }
    it { expect(rendered).to render_template('meursing_lookup/steps/_form') }
    it { expect(rendered).to render_template('meursing_lookup/steps/_step') }
  end

  it_behaves_like 'an answer step view', MeursingLookup::Steps::Starch
  it_behaves_like 'an answer step view', MeursingLookup::Steps::Sucrose
  it_behaves_like 'an answer step view', MeursingLookup::Steps::MilkFat
  it_behaves_like 'an answer step view', MeursingLookup::Steps::MilkProtein

  context 'when the current step is an start step' do
    let(:current_step) { MeursingLookup::Steps::Start.new(wizard, store) }

    it { expect(rendered).to render_template('meursing_lookup/steps/show') }
    it { expect(rendered).to render_template('meursing_lookup/steps/_start') }
  end

  context 'when the current step is a review_answer step' do
    let(:current_step) { MeursingLookup::Steps::ReviewAnswers.new(wizard, store) }

    it { expect(rendered).to render_template('meursing_lookup/steps/_form') }
    it { expect(rendered).to render_template('meursing_lookup/steps/_review_answers') }
    it { expect(rendered).to render_template('meursing_lookup/steps/_review_answer') }
  end

  context 'when the current step is an end step' do
    let(:current_step) { instance_double(MeursingLookup::Steps::End, key: 'end', meursing_code: '4001') }

    it { expect(rendered).to render_template('meursing_lookup/steps/show') }
    it { expect(rendered).to render_template('meursing_lookup/steps/_end') }
  end
end
