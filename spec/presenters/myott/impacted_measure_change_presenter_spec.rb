require 'spec_helper'

RSpec.describe Myott::ImpactedMeasureChangePresenter do
  subject(:presenter) { described_class.new(change, trade_direction:) }

  let(:trade_direction) { 'import' }

  let(:change) do
    {
      'change_type' => 'Updated',
      'additional_code' => '',
      'quota_order_number' => nil,
      'date_of_effect' => '2026-03-15',
      'date_of_effect_visible' => '2026-03-16',
    }
  end

  describe '#change_type' do
    it { expect(presenter.change_type).to eq('Updated') }
  end

  describe '#additional_code' do
    it { expect(presenter.additional_code).to eq('N/A') }
  end

  describe '#quota_order_number' do
    it { expect(presenter.quota_order_number).to eq('N/A') }
  end

  describe '#date_of_effect' do
    it { expect(presenter.date_of_effect).to eq(Date.new(2026, 3, 15).to_fs) }
  end

  describe '#date_of_effect_visible' do
    it { expect(presenter.date_of_effect_visible).to eq(Date.new(2026, 3, 16).to_fs) }
  end

  describe '#commodity_link_params' do
    it do
      expect(presenter.commodity_link_params).to eq(day: 16, month: 3, year: 2026, anchor: 'import')
    end
  end

  describe '#trade_direction_anchor' do
    context 'when the trade direction is export' do
      let(:trade_direction) { 'export' }

      it { expect(presenter.trade_direction_anchor).to eq('export') }
    end

    context 'when the trade direction is not export' do
      it { expect(presenter.trade_direction_anchor).to eq('import') }
    end
  end
end
