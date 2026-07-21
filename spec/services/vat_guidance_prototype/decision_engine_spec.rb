RSpec.describe VatGuidancePrototype::DecisionEngine do
  subject(:engine) { described_class.new(journey:, applicable_vat_options:) }

  let(:journey) do
    VatGuidancePrototype::RuleRepository.new.find('vegetable_oil_blend')
  end
  let(:applicable_vat_options) { journey.applicable_vat_options }

  it 'starts at the configured first question', :aggregate_failures do
    state = engine.evaluate

    expect(state).to be_question
    expect(state.question.id).to eq('product_identity')
  end

  it 'walks the graph and returns a tariff-provided option', :aggregate_failures do
    state = engine.evaluate(
      'product_identity' => 'yes',
      'intended_use' => 'animal_feed',
      'feed_processing' => 'yes',
    )

    expect(state).to be_determined
    expect(state.vat_option).to eq('VATZ')
    expect(state.trail.map { |item| item[:question].id }).to eq(
      %w[product_identity intended_use feed_processing],
    )
  end

  it 'returns unable when the rules deliberately abstain', :aggregate_failures do
    state = engine.evaluate('product_identity' => 'no')

    expect(state).to be_unable
    expect(state.reason).to include('does not match')
  end

  it 'does not return an outcome absent from the current tariff options', :aggregate_failures do
    engine = described_class.new(journey:, applicable_vat_options: { 'VAT' => 'Standard rate' })
    state = engine.evaluate(
      'product_identity' => 'yes',
      'intended_use' => 'animal_feed',
      'feed_processing' => 'yes',
    )

    expect(state).to be_unable
    expect(state.reason).to include('not available in the current tariff data')
  end

  it 'rejects an answer that is not defined for the question' do
    expect { engine.evaluate('product_identity' => 'invented') }
      .to raise_error(described_class::InvalidAnswer)
  end

  it 'selects standard rate when the blend is supplied as road fuel', :aggregate_failures do
    state = engine.evaluate(
      'product_identity' => 'yes',
      'intended_use' => 'road_fuel',
    )

    expect(state).to be_determined
    expect(state.vat_option).to eq('VAT')
  end

  it 'abstains where a potentially reduced fuel option is absent from tariff data', :aggregate_failures do
    state = engine.evaluate(
      'product_identity' => 'yes',
      'intended_use' => 'other_fuel',
    )

    expect(state).to be_unable
    expect(state.reason).to include('reduced-rated')
  end

  describe 'live bees' do
    let(:journey) { VatGuidancePrototype::RuleRepository.new.find('bees') }

    it 'zero-rates honey bees that remain in the human food chain' do
      state = engine.evaluate(
        'product_identity' => 'yes',
        'bee_type' => 'honey_bees',
        'food_chain_status' => 'no',
      )

      expect(state.vat_option).to eq('VATZ')
    end

    it 'standard-rates bumble bees' do
      state = engine.evaluate(
        'product_identity' => 'yes',
        'bee_type' => 'bumble_bees',
      )

      expect(state.vat_option).to eq('VAT')
    end

    it 'abstains for another type of bee' do
      state = engine.evaluate(
        'product_identity' => 'yes',
        'bee_type' => 'other',
      )

      expect(state).to be_unable
    end
  end

  describe "children's picture books" do
    let(:journey) { VatGuidancePrototype::RuleRepository.new.find('childrens_picture_books') }

    it 'zero-rates a qualifying standalone children’s book' do
      state = engine.evaluate(
        'product_identity' => 'yes',
        'mixed_supply' => 'yes',
        'essentially_a_toy' => 'no',
        'suitable_for_children' => 'yes',
      )

      expect(state.vat_option).to eq('VATZ')
    end

    it 'standard-rates a product that is essentially a toy' do
      state = engine.evaluate(
        'product_identity' => 'yes',
        'mixed_supply' => 'yes',
        'essentially_a_toy' => 'yes',
      )

      expect(state.vat_option).to eq('VAT')
    end

    it 'abstains for a mixed supply' do
      state = engine.evaluate(
        'product_identity' => 'yes',
        'mixed_supply' => 'no',
      )

      expect(state).to be_unable
    end
  end

  describe 'vegetable and strawberry plants' do
    let(:journey) { VatGuidancePrototype::RuleRepository.new.find('vegetable_and_strawberry_plants') }

    it 'zero-rates plants held out for producing food' do
      state = engine.evaluate(
        'product_identity' => 'yes',
        'intended_purpose' => 'food',
      )

      expect(state.vat_option).to eq('VATZ')
    end

    it 'standard-rates ornamental plants' do
      state = engine.evaluate(
        'product_identity' => 'yes',
        'intended_purpose' => 'ornamental',
      )

      expect(state.vat_option).to eq('VAT')
    end
  end
end
