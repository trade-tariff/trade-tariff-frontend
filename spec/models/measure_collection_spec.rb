require 'spec_helper'

describe MeasureCollection do
  describe '#for_country' do
    let(:measure1) { Measure.new(attributes_for(:measure, geographical_area: { geographical_area_id: 'IT' }).stringify_keys) }
    let(:measure2) { Measure.new(attributes_for(:measure, geographical_area: { geographical_area_id: 'RU' }).stringify_keys) }
    let(:collection) { MeasureCollection.new([measure1, measure2]) }

    it 'filters measures by country code' do
      expect(
        collection.for_country('IT'),
      ).not_to include measure2
    end
  end

  describe '#vat' do
    let(:measure1) { Measure.new(attributes_for(:measure, :vat).stringify_keys) }
    let(:measure2) { Measure.new(attributes_for(:measure).stringify_keys) }
    let(:collection) { MeasureCollection.new([measure1, measure2]) }

    it 'filters VAT measures' do
      expect(collection.vat).not_to include measure2
    end
  end

  describe '#national' do
    let(:measure1) { Measure.new(attributes_for(:measure, :national).stringify_keys) }
    let(:measure2) { Measure.new(attributes_for(:measure).stringify_keys) }
    let(:collection) { MeasureCollection.new([measure1, measure2]) }

    it 'filters national measures' do
      expect(collection.national).not_to include measure2
    end
  end

  describe '#to_a' do
    context 'presenter class given (default)' do
      let(:measure) { Measure.new(attributes_for(:measure).stringify_keys) }
      let(:collection) { MeasureCollection.new([measure]) }

      it 'returns an Array' do
        expect(collection.to_a).to be_kind_of Array
      end

      it 'returns array of Measures wrapped in Presenter objects' do
        expect(collection.to_a.first).to be_kind_of collection.presenter_klass
      end
    end

    context 'presenter class blank' do
      let(:measure) { Measure.new(attributes_for(:measure).stringify_keys) }
      let(:collection) { MeasureCollection.new([measure], nil) }

      it 'returns an Array' do
        expect(collection.to_a).to be_kind_of Array
      end

      it 'returns plain Measure object array' do
        expect(collection.to_a.first).to be_kind_of Measure
      end
    end
  end

  describe '#present?' do
    context 'measures present' do
      subject { MeasureCollection.new([measure]) }

      let(:measure) { Measure.new(attributes_for(:measure).stringify_keys) }

      it 'returns true' do
        expect(subject).to be_present
      end
    end

    context 'measures blank' do
      subject { MeasureCollection.new([]) }

      it 'returns false' do
        expect(subject).not_to be_present
      end
    end
  end
end
