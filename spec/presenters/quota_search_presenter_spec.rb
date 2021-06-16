require 'spec_helper'

describe QuotaSearchPresenter do
  describe '#initialize' do
    let(:order_number_definition) { build(:definition, quota_definition_sid: quota_definition_sid) }
    let(:quota_definition_sid) { -1200 }
    let(:quota_search_present) { described_class.new(search_form) }
    let(:search_form) { QuotaSearchForm.new({}) }

    before do
      allow(search_form).to receive(:present?).and_return(true)
      allow(OrderNumber::Definition).to receive(:search).and_return([order_number_definition])
    end

    context 'when quota_definition_sid is negative' do
      it 'filters out the definitions that have a negative quota_definition_sid' do
        expect(quota_search_present.search_result).to be_empty
      end
    end

    context 'when quota_definition_sid is positive' do
      let(:quota_definition_sid) { 1200 }

      it 'does not filter out the definitions that have a negative quota_definition_sid' do
        expect(quota_search_present.search_result).to include(order_number_definition)
      end
    end
  end
end
