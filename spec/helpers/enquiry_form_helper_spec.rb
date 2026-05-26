require 'spec_helper'

RSpec.describe EnquiryFormHelper, :aggregate_failures, type: :helper do
  describe '.fields' do
    it 'returns the revised field order' do
      expect(described_class.fields).to eq(%w[category goods_details commodity_code query contact_details])
    end
  end

  describe '.permitted_fields' do
    it 'returns the answer fields collected by the journey' do
      expect(described_class.permitted_fields).to include(
        'category',
        'goods_product',
        'goods_made_of',
        'has_commodity_code',
        'commodity_code',
        'query',
        'email_address',
      )
    end
  end

  describe '#partial_for_field' do
    it { expect(helper.partial_for_field('category')).to eq('category') }
    it { expect(helper.partial_for_field('goods_details')).to eq('goods_details') }
    it { expect(helper.partial_for_field('unknown')).to eq('unknown_field') }
  end

  describe '#category_options' do
    it 'contains the agreed category labels' do
      expect(helper.category_options.pluck(:label)).to eq(
        [
          'Classification',
          'Import Duties and Quota',
          'Origin',
          'Valuation',
          'Developer Portal',
          'Stop Press and Commodity Code watch lists',
          'Other',
        ],
      )
    end
  end

  describe '#display_value_for' do
    it 'returns the category label for stored category values' do
      expect(helper.display_value_for('category', 'classification')).to eq('Classification')
    end

    it 'returns yes and no labels for commodity code answers' do
      expect(helper.display_value_for('has_commodity_code', 'yes')).to eq('Yes')
      expect(helper.display_value_for('has_commodity_code', 'no')).to eq('No')
    end
  end

  describe '#field_value' do
    it 'returns the value from the supplied enquiry data' do
      expect(helper.field_value('email_address', { 'email_address' => 'trader@example.com' })).to eq('trader@example.com')
    end
  end
end
