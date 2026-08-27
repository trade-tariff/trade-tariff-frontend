RSpec.describe VatGuidancePrototype::ComposedJourneyRepository do
  subject(:repository) { described_class.new }

  before { stub_vat_guidance_demo }

  describe '#for_commodity' do
    it 'returns the composed and associated notice journeys for a prepared-food commodity' do
      expect(repository.for_commodity('2005202000').map(&:id)).to contain_exactly(
        '2005202000',
        'notice-701-14-food-exceptions',
        'notice-709-1-catering-reference-expanded',
      )
    end

    it 'does not return food notice guidance for an unrelated commodity' do
      expect(repository.for_commodity('8407100010')).to be_empty
    end
  end

  it 'loads non-production composed journeys from the backend artifact', :aggregate_failures do
    journey = repository.find('2005202000')

    expect(repository.spike_status).to include('runtime_approved' => false, 'production_ready' => false)
    expect(journey.commodity_code).to eq('2005202000')
    expect(journey.title).to eq('Commodity 20 05 20 20 00')
    expect(journey.production_eligible).to be(false)
    expect(journey.routes.size).to eq(2)
  end

  it 'loads the evidence-only 709/1 notice comparison without a commodity or measure connection', :aggregate_failures do
    journey = repository.find('notice-709-1-catering-reference-expanded')

    expect(journey.kind).to eq('notice')
    expect(journey.commodity_code).to be_nil
    expect(journey.evidence_only).to be(true)
    expect(journey.review_mode).to eq('pending_domain_review')
    expect(journey.production_eligible).to be(false)
    expect(journey.routes).to contain_exactly(
      include('treatment' => 'standard', 'additional_code' => nil, 'measure_ids' => []),
      include('treatment' => 'standard', 'additional_code' => nil, 'measure_ids' => []),
      include('treatment' => 'zero', 'additional_code' => nil, 'measure_ids' => []),
    )
  end

  it 'rejects an artifact that claims runtime approval' do
    response = vat_guidance_demo_response
    response.dig('data', 'attributes', 'spike_status')['runtime_approved'] = true
    stub_vat_guidance_demo(response)

    expect { repository.all }.to raise_error(described_class::InvalidArtifact, /safety status is invalid/)
  end

  it 'rejects an evidence-only notice journey containing a measure connection' do
    response = vat_guidance_demo_response
    route = response.dig('data', 'attributes', 'notice_journeys', 0, 'resolved_answer_paths', 0)
    route['additional_code'] = 'VATZ'
    route['measure_ids'] = ['-1']
    route['connection_ids'] = ['connection-proposal:unsafe']
    stub_vat_guidance_demo(response)

    expect { repository.all }.to raise_error(described_class::InvalidArtifact, /notice journeys are not safe/)
  end
end
