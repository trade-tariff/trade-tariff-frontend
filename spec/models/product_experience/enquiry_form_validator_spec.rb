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

    [
      ['enquiry_type', {}, [{ field: 'enquiry_type', message: 'Please select what your enquiry relates to.' }]],
      ['enquiry_type', { 'enquiry_type' => 'invalid' }, [{ field: 'enquiry_type', message: 'Please select what your enquiry relates to.' }]],
      ['duty_details', {}, [{ field: 'query', message: 'Please explain how we can help.' }]],
      ['quota_details', {}, [
        { field: 'quota_reference_type', message: 'Please select whether you have a commodity code or quota order number.' },
        { field: 'query', message: 'Please explain how we can help.' },
      ]],
      ['quota_details', { 'quota_reference_type' => 'invalid', 'query' => 'Can I use this quota?' }, [{ field: 'quota_reference_type', message: 'Please select whether you have a commodity code or quota order number.' }]],
      ['quota_details', { 'quota_reference_type' => 'commodity_code', 'query' => 'Can I use this quota?' }, [{ field: 'quota_commodity_code', message: 'Please enter the commodity code.' }]],
      ['quota_details', { 'quota_reference_type' => 'quota_order_number', 'query' => 'Can I use this quota?' }, [{ field: 'quota_order_number', message: 'Please enter the quota order number.' }]],
      ['quota_details', { 'quota_reference_type' => 'movement_reference_number', 'query' => 'Can I use this quota?' }, [{ field: 'movement_reference_number', message: 'Please enter the Movement Reference Number (MRN).' }]],
      ['postal_or_baggage_details', {}, [
        { field: 'postal_or_baggage', message: 'Please select what you are asking about.' },
        { field: 'item', message: 'Please enter the item.' },
        { field: 'purchase_price', message: 'Please enter the purchase price.' },
        { field: 'query', message: 'Please explain how we can help.' },
      ]],
    ].each do |field, data, errors|
      it "validates #{field} details" do
        expect(described_class.errors_for(field, data)).to eq(errors)
      end
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
