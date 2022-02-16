require 'spec_helper'

RSpec.describe TariffUpdate do
  describe '#applied_at' do
    subject(:applied_at) { build(:tariff_update).applied_at }

    it { is_expected.to be_kind_of Date }
  end

  describe '.latest_applied_import_date' do
    subject(:latest_applied_import_date) { described_class.latest_applied_import_date }

    it { is_expected.to eq(Time.zone.today) }
  end
end
