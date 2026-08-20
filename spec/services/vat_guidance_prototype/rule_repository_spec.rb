RSpec.describe VatGuidancePrototype::RuleRepository do
  subject(:repository) { described_class.new }

  def with_modified_rules
    rules = YAML.safe_load_file(described_class::DEFAULT_PATH, aliases: false)
    yield rules

    path = Rails.root.join("tmp/vat-guidance-rules-#{SecureRandom.hex}.yml")
    File.write(path, rules.to_yaml)
    repository = described_class.new(path:)
    repository.all
    repository
  ensure
    File.delete(path) if path&.exist?
  end

  it 'provides one compiled default repository for runtime use' do
    expect(described_class.default).to equal(described_class.default)
  end

  it 'loads all reviewed product mappings' do
    expect(repository.all.map(&:id)).to contain_exactly(
      'bees',
      'childrens_picture_books',
      'vegetable_and_strawberry_plants',
      'vegetable_oil_blend',
    )
  end

  it 'captures the explicit commodity code and prototype VAT options', :aggregate_failures do
    journey = repository.find('vegetable_oil_blend')

    expect(journey).to be_reviewed
    expect(journey).not_to be_generic
    expect(journey.commodity_codes).to eq(%w[1516209821])
    expect(journey.applicable_vat_options.keys).to contain_exactly('VATZ', 'VAT')
  end

  it 'provides independently effective-dated rule and classification metadata', :aggregate_failures do
    journey = repository.find('vegetable_oil_blend')

    expect(journey.content_version).to eq(3)
    expect(journey.guidance_version_from).to eq(Date.new(2025, 2, 5))
    expect(journey.applicability_from).to eq(Date.new(2010, 8, 13))
    expect(journey.guidance_version_to).to be_nil
    expect(journey.applicability_to).to be_nil
    expect(journey.sources.first.url).to start_with('https://www.gov.uk/')
  end

  it 'applies guidance dates, applicability dates and jurisdictions', :aggregate_failures do
    expect(repository.find_by_commodity('1516209821', as_of: Date.new(2025, 2, 4))).to be_nil
    expect(repository.find_by_commodity('1516209821', jurisdiction: :xi)).to be_nil
    expect(repository.find_by_commodity('1516209821', as_of: Date.new(2025, 2, 5))).to be_present

    expired_repository = with_modified_rules do |rules|
      rules.dig('applicability', 'vegetable_oil_blend')['effective_to'] = '2026-07-20'
    end
    expect(expired_repository.find_by_commodity('1516209821', as_of: Date.new(2026, 7, 21))).to be_nil
  end

  it 'matches explicit codes rather than commodity prefixes', :aggregate_failures do
    expect(repository.find_by_commodity('1516209821')).to be_present
    expect(repository.find_by_commodity('1516209822')).to be_nil
    expect(repository.find_by_commodity('1516200000')).to be_nil
  end

  it 'maps the three additional reviewed commodities by exact code', :aggregate_failures do
    expect(repository.find_by_commodity('0106410000').id).to eq('bees')
    expect(repository.find_by_commodity('4903000000').id).to eq('childrens_picture_books')
    expect(repository.find_by_commodity('0602903000').id).to eq('vegetable_and_strawberry_plants')
    expect(repository.find_by_commodity('0106410001')).to be_nil
    expect(repository.find_by_commodity('4903000001')).to be_nil
    expect(repository.find_by_commodity('0602903001')).to be_nil
  end

  it 'supports audited reuse of one rule set across an explicit code list', :aggregate_failures do
    shared_repository = with_modified_rules do |rules|
      rules.dig('applicability', 'vegetable_oil_blend', 'commodity_codes') << '1516209822'
    end

    first = shared_repository.find_by_commodity('1516209821')
    second = shared_repository.find_by_commodity('1516209822')

    expect(first).to equal(second)
    expect(second.rule_set_id).to eq('animal_feed_oils')
  end

  it 'rejects an applicability mapping that is not marked reviewed' do
    build_repository = lambda do
      with_modified_rules do |rules|
        rules.dig('applicability', 'vegetable_oil_blend')['review_status'] = 'draft'
      end
    end

    expect(&build_repository).to raise_error(described_class::InvalidRules, /is not reviewed/)
  end

  it 'raises a specific error for an unknown journey' do
    expect { repository.find('unknown') }
      .to raise_error(described_class::JourneyNotFound, 'unknown')
  end
end
