require 'spec_helper'

RSpec.describe EnquiryFormHelper, type: :helper do
  describe '.fields' do
    it 'returns all defined field keys' do
      expect(described_class.fields).to match_array(%w[
        full_name company_name occupation email_address category query
      ])
    end
  end

  describe '#partial_for_field' do
    it 'returns correct partial for known field' do
      expect(helper.partial_for_field('email_address')).to eq('text_field')
    end

    it 'returns unknown_field for unrecognised field' do
      expect(helper.partial_for_field('foobar')).to eq('unknown_field')
    end
  end

  describe '#required_field?' do
    it 'returns false for optional fields' do
      expect(required_field?('company_name')).to be false
    end

    it 'returns true for required fields' do
      expect(required_field?('full_name')).to be true
    end
  end

  describe '#error_message_for' do
    it 'returns specific error messages for known fields' do
      expect(error_message_for('full_name')).to eq('Please enter your full name.')
    end

    it 'returns default error for unknown fields' do
      expect(error_message_for('foobar')).to eq('Please enter a value.')
    end
  end

  describe '#field_type' do
    it 'returns text area types for query field' do
      expect(field_type('query')).to eq(:text_area)
    end

    it 'returns radio button partial for query field' do
      expect(field_type('category')).to eq(:radio_buttons)
    end

    it 'returns :text_field for default fields' do
      expect(field_type('email_address')).to eq(:text_field)
    end
  end

  describe '#field_label' do
    it 'returns specific label for known fields' do
      expect(field_label('occupation')).to eq('Job title (optional)')
    end

    it 'humanizes label for unknown fields' do
      expect(field_label('some_field')).to eq('Some field')
    end
  end

  describe '#field_hint' do
    it 'returns hint text for known fields' do
      expect(field_hint('email_address')).to include('contact you about your enquiry')
    end

    it 'returns nil for unknown fields' do
      expect(field_hint('other_field')).to be_nil
    end
  end

  describe '#radio_button_category_options' do
    it 'returns an array of label/value pairs' do
      expect(radio_button_category_options).to include(%w[Quotas quotas])
    end
  end

  describe '#display_value_for' do
    it 'returns label for category values' do
      expect(display_value_for('category', 'origin')).to eq('Origin (Preferential and non-preferential)')
    end

    it 'returns value as-is for other fields' do
      expect(display_value_for('full_name', 'Alice')).to eq('Alice')
    end
  end

  describe '#field_value' do
    it 'returns field value from session data hash' do
      session_data = { 'query' => 'My question' }
      expect(field_value('query', session_data)).to eq('My question')
    end
  end
end
