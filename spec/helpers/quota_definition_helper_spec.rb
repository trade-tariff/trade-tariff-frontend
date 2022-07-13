require 'spec_helper'

RSpec.describe QuotaDefinitionHelper, type: :helper do
  describe '#start_and_end_dates_for' do
    let(:definition) { build(:definition, validity_start_date: '2021-01-01T00:00:00.000Z', validity_end_date: '2021-12-31T00:00:00.000Z') }

    it 'returns a properly formatted definition' do
      expect(helper.start_and_end_dates_for(definition)).to eq('1 January 2021 to 31 December 2021')
    end
  end

  describe '#supension_period_dates_for' do
    let(:definition) { build(:definition) }

    it 'returns n/a' do
      expect(helper.suspension_period_dates_for(definition)).to eq('n/a')
    end

    context 'when the suspension period dates are defined' do
      let(:definition) { build(:definition, suspension_period_start_date: '2021-01-01T00:00:00.000Z', suspension_period_end_date: '2021-12-31T00:00:00.000Z') }

      it 'returns a properly formatted from and to date' do
        expect(helper.suspension_period_dates_for(definition)).to eq('1 January 2021 to 31 December 2021')
      end
    end
  end

  describe '#blocking_period_dates_for' do
    let(:definition) { build(:definition) }

    it 'returns n/a' do
      expect(helper.blocking_period_dates_for(definition)).to eq('n/a')
    end

    context 'when the suspension period dates are defined' do
      let(:definition) { build(:definition, blocking_period_start_date: '2021-01-01T00:00:00.000Z', blocking_period_end_date: '2021-12-31T00:00:00.000Z') }

      it 'returns a properly formatted from and to date' do
        expect(helper.blocking_period_dates_for(definition)).to eq('1 January 2021 to 31 December 2021')
      end
    end
  end
end
