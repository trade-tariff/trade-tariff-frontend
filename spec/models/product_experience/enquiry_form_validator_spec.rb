require 'spec_helper'

RSpec.describe ProductExperience::EnquiryFormValidator do
  describe '.errors_for' do
    it 'requires a category' do
      expect(described_class.errors_for('category', {})).to eq(
        [{ field: 'category', message: 'Please select what you need help with.' }],
      )
    end

    it 'requires the other category short label when other is selected' do
      expect(described_class.errors_for('category', 'category' => 'other')).to eq(
        [{ field: 'other_category', message: 'Please add a short label.' }],
      )
    end

    it 'requires both mandatory goods detail fields' do
      expect(described_class.errors_for('goods_details', {})).to contain_exactly(
        { field: 'goods_product', message: 'Please describe the product.' },
        { field: 'goods_made_of', message: 'Please say what the product is made of.' },
      )
    end

    it 'requires a possible commodity code choice' do
      expect(described_class.errors_for('commodity_code', {})).to eq(
        [{ field: 'has_commodity_code', message: 'Please select whether you have a possible commodity code.' }],
      )
    end

    it 'requires the possible commodity code when the user says they have one' do
      expect(described_class.errors_for('commodity_code', 'has_commodity_code' => 'yes')).to eq(
        [{ field: 'commodity_code', message: 'Please enter the possible commodity code.' }],
      )
    end

    it 'requires a generic query' do
      expect(described_class.errors_for('query', {})).to eq(
        [{ field: 'query', message: 'Please explain how we can help.' }],
      )
    end

    it 'limits generic queries to 5,000 UTF-16 code units' do
      expect(described_class.errors_for('query', 'query' => 'a' * 5001)).to eq(
        [{ field: 'query', message: 'You can enter up to 5,000 characters.' }],
      )
    end

    it 'requires an email address' do
      expect(described_class.errors_for('contact_details', {})).to eq(
        [{ field: 'email_address', message: 'Please enter your email address.' }],
      )
    end

    it 'requires a valid email address' do
      expect(described_class.errors_for('contact_details', 'email_address' => 'not-an-email')).to eq(
        [{ field: 'email_address', message: 'Please enter a valid email address.' }],
      )
    end
  end
end
