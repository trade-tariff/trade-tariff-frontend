require 'spec_helper'

RSpec.describe QuotaClosedAndTransferredEvent do
  subject(:quota_closed_and_transferred_event) { build(:quota_closed_and_transferred_event) }

  describe '#presented_balance_text' do
    it { expect(quota_closed_and_transferred_event.presented_balance_text).to eq("Kilogram (kg), transferred from the previous quota period (1 January 2021 to 31 December 2021) on #{Date.current.to_formatted_s(:long)}.") }
  end
end
