require 'spec_helper'

RSpec.describe DutyCalculator::Steps::WhatAreYouImporting, :user_session do
  subject(:step) { described_class.new(search_term:) }

  let(:search_term) { '55" 4K Ultra HD OLED Smart TV' }
  let(:user_session) { build(:duty_calculator_user_session) }

  describe '#valid?' do
    it { is_expected.to be_valid }

    context 'when the search term is blank' do
      let(:search_term) { '' }

      it 'adds the expected error' do
        step.valid?

        expect(step.errors[:search_term]).to eq(['Enter a search term'])
      end
    end

    context 'when the search term contains only whitespace' do
      let(:search_term) { '   ' }

      it 'adds the expected error' do
        step.valid?

        expect(step.errors[:search_term]).to eq(['Enter a search term'])
      end
    end
  end

  describe '#save!' do
    before { step.save! }

    it 'stores the search term in the user session' do
      expect(user_session.what_are_you_importing).to eq(search_term)
    end
  end

  describe '#search_term' do
    before { user_session.what_are_you_importing = '8528 72 40 00' }

    it 'prefills the saved search term' do
      expect(described_class.new.search_term).to eq('8528 72 40 00')
    end
  end

  describe '#previous_step_path' do
    it 'returns to the homepage import details page' do
      expect(step.previous_step_path).to eq(homepage_import_details_path)
    end

    context 'when a previous calculator journey left a commodity in the session' do
      before { user_session.commodity_code = '8528724000' }

      it 'still returns to the homepage import details page' do
        expect(step.previous_step_path).to eq(homepage_import_details_path)
      end
    end
  end
end
