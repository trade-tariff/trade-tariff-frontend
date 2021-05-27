require 'spec_helper'

describe MeasuresHelper, type: :helper do
  describe '#show_warning?' do
    let(:order_number) do
      build(:order_number, number: number, definition: attributes_for(:definition, description: description))
    end
    let(:description) { nil }
    let(:number) { '050000' }

    context 'when there is a description and the order number starts with `05`' do
      let(:description) { 'foo' }
      let(:number) { '050000' }

      it { expect(helper).to be_show_warning(order_number) }
    end

    context 'when there is a description and the order number does not start with 05' do
      let(:description) { 'foo' }
      let(:number) { '060000' }

      it { expect(helper).not_to be_show_warning(order_number) }
    end

    context 'when there is no description' do
      let(:description) { nil }

      it { expect(helper).not_to be_show_warning(order_number) }
    end
  end

  describe '#start_and_end_dates_for' do
    let(:definition) { build(:definition, validity_start_date: '2021-01-01T00:00:00.000Z', validity_end_date: '2021-12-31T00:00:00.000Z') }

    it 'returns a properly formatted definition' do
      expect(helper.start_and_end_dates_for(definition)).to eq(' 1 January 2021 to 31 December 2021')
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
        expect(helper.suspension_period_dates_for(definition)).to eq(' 1 January 2021 to 31 December 2021')
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
        expect(helper.blocking_period_dates_for(definition)).to eq(' 1 January 2021 to 31 December 2021')
      end
    end
  end
end
