require 'spec_helper'

RSpec.describe ProductExperience::EnquiryFormJourney, :aggregate_failures do
  describe '.normalized_data' do
    it 'removes generic answers when the category route changes to classification' do
      data = described_class.normalized_data(
        'category',
        {
          'category' => 'valuation',
          'query' => 'I need help with valuation.',
          'email_address' => 'trader@example.com',
        },
        { 'category' => 'classification' },
      )

      expect(data).to include(
        'category' => 'classification',
        'email_address' => 'trader@example.com',
      )
      expect(data).not_to include('query')
    end

    it 'removes classification answers when the category route changes to a generic route' do
      data = described_class.normalized_data(
        'category',
        {
          'category' => 'classification',
          'goods_product' => 'Embroidery floss',
          'goods_made_of' => 'Cotton',
          'has_commodity_code' => 'yes',
          'commodity_code' => '5204200010',
          'email_address' => 'trader@example.com',
        },
        { 'category' => 'valuation' },
      )

      expect(data).to include(
        'category' => 'valuation',
        'email_address' => 'trader@example.com',
      )
      expect(data).not_to include(
        'goods_product',
        'goods_made_of',
        'has_commodity_code',
        'commodity_code',
      )
    end

    it 'removes stale duties and quotas route answers' do
      data = described_class.normalized_data(
        'category',
        { 'category' => 'classification', 'goods_product' => 'Embroidery floss', 'query' => 'Old query' },
        { 'category' => 'import_duties_and_quota' },
      )
      expect(data).not_to include('goods_product', 'query')

      data = described_class.normalized_data(
        'enquiry_type',
        {
          'category' => 'import_duties_and_quota',
          'enquiry_type' => 'import_duties',
          'duty_commodity_code' => '0101210000',
          'customs_value' => '100',
          'query' => 'Can you check the duty?',
        },
        { 'enquiry_type' => 'quotas' },
      )
      expect(data).to include('category' => 'import_duties_and_quota', 'enquiry_type' => 'quotas', 'query' => 'Can you check the duty?')
      expect(data).not_to include('duty_commodity_code', 'customs_value')
    end

    it 'removes the other category label when the selected category is not other' do
      data = described_class.normalized_data(
        'category',
        { 'category' => 'other', 'other_category' => 'Tariff question' },
        { 'category' => 'origin' },
      )

      expect(data).to eq('category' => 'origin')
    end

    it 'removes the possible commodity code when the user changes their answer to no' do
      data = described_class.normalized_data(
        'commodity_code',
        {
          'category' => 'classification',
          'has_commodity_code' => 'yes',
          'commodity_code' => '9403208090',
        },
        { 'has_commodity_code' => 'no' },
      )

      expect(data).to include(
        'category' => 'classification',
        'has_commodity_code' => 'no',
      )
      expect(data).not_to include('commodity_code')
    end

    it 'removes stale quota reference values when the selected reference type changes' do
      [
        ['commodity_code', 'quota_commodity_code', %w[quota_order_number movement_reference_number]],
        ['quota_order_number', 'quota_order_number', %w[quota_commodity_code movement_reference_number]],
        ['movement_reference_number', 'movement_reference_number', %w[quota_commodity_code quota_order_number]],
        ['no', nil, %w[quota_commodity_code quota_order_number movement_reference_number]],
      ].each do |reference_type, retained_field, stale_fields|
        data = described_class.normalized_data(
          'quota_details',
          {
            'quota_reference_type' => 'commodity_code',
            'quota_commodity_code' => '1701991000',
            'quota_order_number' => '054010',
            'movement_reference_number' => '24GB12345678901234',
          },
          { 'quota_reference_type' => reference_type },
        )

        expect(data).to include('quota_reference_type' => reference_type)
        expect(data).to include(retained_field) if retained_field
        expect(data).not_to include(*stale_fields)
      end
    end
  end

  describe '.next_field' do
    it 'routes classification enquiries through the goods details step' do
      expect(described_class.next_field('category', 'category' => 'classification')).to eq('goods_details')
    end

    it 'routes non-classification enquiries through the query step' do
      expect(described_class.next_field('category', 'category' => 'valuation')).to eq('query')
    end

    it 'routes classification goods details through possible commodity code' do
      expect(described_class.next_field('goods_details', 'category' => 'classification')).to eq('commodity_code')
    end
  end

  describe '.previous_field' do
    it 'routes contact details back to commodity code for classification' do
      expect(described_class.previous_field('contact_details', 'category' => 'classification')).to eq('commodity_code')
    end

    it 'routes contact details back to query for generic enquiries' do
      expect(described_class.previous_field('contact_details', 'category' => 'valuation')).to eq('query')
    end
  end

  describe '.active_fields' do
    it 'returns the classification journey fields for classification enquiries' do
      expect(described_class.active_fields('category' => 'classification')).to eq(
        %w[category goods_details commodity_code contact_details],
      )
    end

    it 'returns the generic journey fields for non-classification enquiries' do
      expect(described_class.active_fields('category' => 'origin')).to eq(
        %w[category query contact_details],
      )
    end

    it 'returns only the category field before a category has been selected' do
      expect(described_class.active_fields({})).to eq(%w[category])
    end
  end

  describe '.continue_journey_after_edit?' do
    it 'continues the journey when editing category changes the route' do
      expect(
        described_class.continue_journey_after_edit?(
          'category',
          { 'category' => 'classification' },
          { 'category' => 'valuation' },
        ),
      ).to be(true)
    end

    it 'returns to check answers when editing does not change the route' do
      expect(
        described_class.continue_journey_after_edit?(
          'query',
          { 'category' => 'valuation' },
          { 'category' => 'valuation' },
        ),
      ).to be(false)
    end
  end
end
