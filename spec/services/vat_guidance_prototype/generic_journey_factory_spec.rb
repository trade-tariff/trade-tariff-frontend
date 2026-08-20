RSpec.describe VatGuidancePrototype::GenericJourneyFactory do
  subject(:journey) do
    described_class.new(
      commodity_code: '0106330000',
      vat_options: {
        'VATZ' => 'VAT zero rate',
        'VAT' => 'Value added tax (20.0%)',
      },
    ).call
  end

  it 'builds a generic journey from the live commodity options', :aggregate_failures do
    expect(journey).to be_generic
    expect(journey).not_to be_reviewed
    expect(journey.commodity_codes).to eq(%w[0106330000])
    expect(journey.allowed_outcomes).to contain_exactly('VATZ', 'VAT')
    expect(journey.applicable_vat_options).to eq(
      'VATZ' => 'VAT zero rate',
      'VAT' => 'Value added tax (20.0%)',
    )
  end

  it 'requires independent confirmation before presenting the options', :aggregate_failures do
    first_question = journey.questions.fetch('independent_confirmation')
    option_question = journey.questions.fetch('confirmed_option')

    expect(first_question.answers.find { |answer| answer.id == 'yes' }.next_question).to eq('confirmed_option')
    expect(option_question.answers.filter_map(&:outcome)).to contain_exactly('VATZ', 'VAT')
    expect(option_question.answers.find { |answer| answer.id == 'not_sure' }.unable_reason).to be_present
  end

  it 'provides traceable official guidance sources' do
    expect(journey.sources.map(&:url)).to all(start_with('https://www.gov.uk/'))
  end

  it 'rejects a commodity without a VAT choice' do
    build_journey = lambda do
      described_class.new(
        commodity_code: '0702001007',
        vat_options: { 'VATZ' => 'VAT zero rate' },
      ).call
    end

    expect(&build_journey).to raise_error(ArgumentError, 'A generic journey requires more than one VAT option')
  end
end
