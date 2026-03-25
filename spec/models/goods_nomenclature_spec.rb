require 'spec_helper'

RSpec.describe GoodsNomenclature do
  it { is_expected.to respond_to :description_plain }

  describe '.relationships' do
    let(:expected_relationships) { %i[ancestors] }

    it { expect(described_class.relationships).to match_array(expected_relationships) }
  end

  describe '#validity_start_date=' do
    let(:goods_nomenclature) { described_class.new }

    context 'with passed date present' do
      it 'sets date' do
        goods_nomenclature.validity_start_date = Time.zone.today

        expect(goods_nomenclature.validity_start_date).to eq Time.zone.today.to_date
      end
    end

    context 'with blank passed date' do
      it 'does not set validity end date' do
        goods_nomenclature.validity_start_date = nil

        expect(goods_nomenclature.validity_start_date).to be_blank
      end
    end
  end

  describe '#validity_end_date=' do
    let(:goods_nomenclature) { described_class.new }

    context 'with passed date present' do
      it 'sets date' do
        goods_nomenclature.validity_end_date = Time.zone.today

        expect(goods_nomenclature.validity_end_date).to eq Time.zone.today.to_date
      end
    end

    context 'with blank passed date' do
      it 'does not set validity end date' do
        goods_nomenclature.validity_end_date = nil

        expect(goods_nomenclature.validity_end_date).to be_blank
      end
    end
  end

  describe '#validity_start_date' do
    context 'with the date set' do
      let(:goods_nomenclature) do
        build(:goods_nomenclature, validity_start_date: Time.zone.today)
      end

      it 'returns instance of Date' do
        expect(goods_nomenclature.validity_start_date).to be_a Date
      end

      it 'returns parsed date' do
        expect(goods_nomenclature.validity_start_date).to eq Time.zone.today.to_date
      end
    end

    context 'without the date set' do
      let(:goods_nomenclature) do
        build(:goods_nomenclature, validity_start_date: nil)
      end

      it 'returns NullObject' do
        expect(goods_nomenclature.validity_start_date).to be_a NullObject
      end
    end
  end

  describe '#validity_end_date' do
    context 'with the date set' do
      let(:goods_nomenclature) do
        build(:goods_nomenclature, validity_end_date: Time.zone.today)
      end

      it 'returns instance of Date' do
        expect(goods_nomenclature.validity_end_date).to be_a Date
      end

      it 'returns parsed date' do
        expect(goods_nomenclature.validity_end_date).to eq Time.zone.today.to_date
      end
    end

    context 'without the date set' do
      let(:goods_nomenclature) do
        build(:goods_nomenclature, validity_end_date: nil)
      end

      it 'returns NullObject' do
        expect(goods_nomenclature.validity_end_date).to be_a NullObject
      end
    end
  end

  describe '#rules_of_origin' do
    before do
      # Needed because goods nomenclature isn't declarable but #rules_of_origin
      # short circuits for any non-declarable nomenclatures
      allow(goods_nomenclature).to receive(:declarable?).and_return true
    end

    let(:goods_nomenclature) { build(:goods_nomenclature) }

    context 'without country param' do
      it 'raises an exception' do
        expect { goods_nomenclature.rules_of_origin }.to raise_exception ArgumentError
      end
    end

    context 'with country param' do
      subject(:rules) { goods_nomenclature.rules_of_origin('FR') }

      before do
        allow(RulesOfOrigin::Scheme).to receive(:for_heading_and_country)
          .with(goods_nomenclature.code, 'FR')
          .and_return([])
      end

      it 'chains chain to RulesOfOrigin::Scheme' do
        rules # trigger call

        expect(RulesOfOrigin::Scheme).to have_received(:for_heading_and_country)
          .with(goods_nomenclature.code, 'FR')
      end
    end

    context 'with country param and additional params' do
      subject(:rules) do
        goods_nomenclature.rules_of_origin('FR', page: 1)
      end

      before do
        allow(RulesOfOrigin::Scheme).to receive(:for_heading_and_country)
          .with(goods_nomenclature.code, 'FR', page: 1)
          .and_return([])
      end

      it 'chains chain to RulesOfOrigin::Scheme' do
        rules # trigger call

        expect(RulesOfOrigin::Scheme).to have_received(:for_heading_and_country)
          .with(goods_nomenclature.code, 'FR', page: 1)
      end
    end
  end

  describe '#rules_of_origin_rules' do
    subject { goods_nomenclature.rules_of_origin_rules(country_code) }

    before do
      allow(goods_nomenclature).to \
        receive(:rules_of_origin).with(country_code).and_return schemes
    end

    let(:goods_nomenclature) { build :goods_nomenclature }
    let(:schemes) { build_list :rules_of_origin_scheme, 2 }
    let(:country_code) { schemes.first.countries.first }

    it { is_expected.to have_attributes length: 6 }
    it { is_expected.to eql schemes.map(&:rules).flatten }
  end

  describe '#is_other?' do
    shared_examples 'a goods nomenclature with an `other` description' do |formatted_description|
      subject(:goods_nomenclature) { build(:commodity, formatted_description:) }

      it { is_expected.to be_is_other }
    end

    it_behaves_like 'a goods nomenclature with an `other` description', 'Other'
    it_behaves_like 'a goods nomenclature with an `other` description', 'other'
    it_behaves_like 'a goods nomenclature with an `other` description', 'OTHER'

    context 'when the description is `nil`' do
      subject(:goods_nomenclature) { build(:commodity, formatted_description: nil) }

      it { is_expected.not_to be_is_other }
    end

    context 'when the description is anything else' do
      subject(:goods_nomenclature) { build(:commodity, formatted_description: 'foo') }

      it { is_expected.not_to be_is_other }
    end
  end

  describe '#formatted_self_text' do
    subject(:formatted_self_text) { goods_nomenclature.formatted_self_text }

    let(:goods_nomenclature) do
      described_class.new(
        'self_text' => self_text,
      )
    end

    context 'when the text contains safe inline html and embedded goods codes' do
      let(:self_text) do
        'Motor cars for <= 10 persons, cylinder capacity <= 1000 cm<sup>3</sup>, used (excl. vehicles of subheading 8703.10)' \
          '<script>alert(1)</script>'
      end

      it 'renders sup tags' do
        expect(formatted_self_text).to include('cm<sup>3</sup>')
      end

      it 'strips unsafe tags' do
        expect(formatted_self_text).not_to include('<script>')
      end

      it 'linkifies dotted goods codes to a new tab search link' do
        expect(formatted_self_text).to include('href="/search?q=870310"')
      end

      it 'opens linkified goods codes in a new tab' do
        expect(formatted_self_text).to include('target="_blank"')
      end

      it 'adds a safe rel attribute to generated goods code links' do
        expect(formatted_self_text).to include('rel="noopener noreferrer"')
      end

      it 'preserves the displayed dotted goods code text' do
        expect(formatted_self_text).to include('>8703.10</a>')
      end

      it 'does not link unrelated numeric values' do
        expect(formatted_self_text).not_to include('href="/search?q=1000"')
      end

      it 'keeps dotted goods codes linked to the full code' do
        expect(formatted_self_text).not_to include('href="/search?q=8703"')
      end
    end
  end

  describe '#formatted_classification_description' do
    subject(:formatted_classification_description) { goods_nomenclature.formatted_classification_description }

    let(:goods_nomenclature) do
      described_class.new(
        'classification_description' => classification_description,
      )
    end

    let(:classification_description) { 'Engine output in cm<sub>3</sub><br>chapter 87' }

    it 'renders allowed formatting tags' do
      expect(formatted_classification_description).to include('cm<sub>3</sub><br>')
    end

    it 'linkifies recognised code references' do
      expect(formatted_classification_description).to include('href="/search?q=87"')
    end

    it 'preserves the displayed chapter reference text' do
      expect(formatted_classification_description).to include('>chapter 87</a>')
    end
  end
end
