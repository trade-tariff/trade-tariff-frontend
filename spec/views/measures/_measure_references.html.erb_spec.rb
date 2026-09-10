require 'spec_helper'

RSpec.describe 'measures/_measure_references', type: :view do
  subject(:rendered_page) do
    render 'measures/measure_references',
           measure: MeasurePresenter.new(measure),
           rules_of_origin_schemes: [scheme],
           declarable: nil,
           anchor: 'test'
  end

  let(:measure) do
    build(
      :measure,
      :import,
      id: '123',
      geographical_area_id: 'FR',
      measure_type: attributes_for(
        :measure_type,
        :tariff_preference,
        semantic_roles:,
      ),
    )
  end

  let(:semantic_roles) { %w[cds_proofs_of_origin] }

  let(:scheme) do
    build(:rules_of_origin_scheme, :with_cds_proof_info, countries: %w[FR])
  end

  it 'renders the proof information for the applicable scheme' do
    expect(rendered_page).to have_css(
      '[data-popup="import-123-cds-proofs"] .cds-proof-info', text: 'Declaring your proof of origin'
    )
  end

  it 'includes the agreement title' do
    expect(rendered_page).to have_css('h2', text: scheme.title)
  end

  context 'when the API does not supply the proofs role' do
    let(:semantic_roles) { [] }

    it { is_expected.not_to have_css '[data-popup="import-123-cds-proofs"]' }
  end
end
