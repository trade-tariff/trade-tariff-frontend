RSpec.describe VatGuidancePrototype::ComposedRouteEngine do
  subject(:engine) { described_class.new(journey:) }

  let(:journey) do
    stub_vat_guidance_demo
    VatGuidancePrototype::ComposedJourneyRepository.new.find('2005202000')
  end

  it 'walks a composed route from its answer prefix to the exact candidate treatment', :aggregate_failures do
    first = engine.evaluate
    second = engine.evaluate([{ question_id: 'catering', answer_id: 'no' }])
    result = engine.evaluate([
      { question_id: 'catering', answer_id: 'no' },
      { question_id: 'packaged-ready', answer_id: 'yes' },
    ])

    expect(first.question.text).to eq('Is the product supplied in the course of catering?')
    expect(first.question.answers.map(&:id)).to contain_exactly('yes', 'no')
    expect(second.question.text).to eq('Is the product packaged and ready to eat?')
    expect(result).to be_determined
    expect(result.route).to include('treatment' => 'zero', 'additional_code' => 'VATZ')
    expect(result.trail.size).to eq(2)
  end

  it 'rejects an answer that is absent from every composed route' do
    expect {
      engine.evaluate([{ question_id: 'catering', answer_id: 'sometimes' }])
    }.to raise_error(described_class::InvalidAnswer, /do not match/)
  end
end
