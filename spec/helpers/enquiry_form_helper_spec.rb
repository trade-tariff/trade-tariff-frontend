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
    let(:session_data) { { 'query' => 'cache_key', 'full_name' => 'Alice' } }

    it 'returns field value from provided session data' do
      expect(field_value('full_name', session_data)).to eq('Alice')
    end

    it 'uses Rails.cache for query field' do
      allow(Rails.cache).to receive(:read).with('cache_key').and_return('Cached question')
      expect(field_value('query', session_data)).to eq('Cached question')
    end

    it 'falls back to session[:enquiry_data] when session_data not passed' do
      session[:enquiry_data] = { 'full_name' => 'Bob' }
      expect(field_value('full_name')).to eq('Bob')
    end
  end

  describe '#validate_value' do
    subject(:validate) { validate_value(field, value) }

    let(:alert) { instance_variable_get(:@alert) }

    context 'when required field is blank' do
      let(:field) { 'full_name' }
      let(:value) { '' }

      it 'sets alert to the correct message' do
        validate
        expect(alert).to eq('Please enter your full name.')
      end
    end

    context 'when email is invalid' do
      let(:field) { 'email_address' }
      let(:value) { 'not-an-email' }

      it 'sets alert to invalid email message' do
        validate
        expect(alert).to eq('Please enter a valid email address.')
      end
    end

    context 'when email is valid' do
      let(:field) { 'email_address' }
      let(:value) { 'user@example.com' }

      it 'does not set alert' do
        validate
        expect(alert).to be_nil
      end
    end

    context 'when query exceeds character limit' do
      let(:field) { 'query' }
      let(:value) { 'a' * 5005 }

      it 'sets alert to length message' do
        validate
        expect(alert).to eq('Please limit your query to 5000 characters or less.')
      end
    end

    context 'when required field has valid value' do
      let(:field) { 'full_name' }
      let(:value) { 'Alice' }

      it 'does not set alert' do
        validate
        expect(alert).to be_nil
      end
    end
  end
end
