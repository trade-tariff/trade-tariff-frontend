require 'spec_helper'

RSpec.describe 'shared/_quota_definition', type: :view do
  subject(:rendered_page) { render_page && rendered }

  before do
    assign :search, Search.new
    allow(view).to receive(:declarable_id)
  end

  let :render_page do
    render 'shared/quota_definition', order_number:, quota_definition:
  end

  let(:quota_definition) { build :definition }
  let(:order_number) { quota_definition.order_number }

  it { is_expected.to have_css 'table h2', text: /Quota order number \d+/ }

  context 'with no suspension or blocking periods' do
    it { is_expected.to have_css 'th', text: 'Suspension / blocking periods' }
  end

  context 'with only suspension period' do
    let :quota_definition do
      build :definition, suspension_period_start_date: Date.yesterday.xmlschema,
                         suspension_period_end_date: Date.tomorrow.xmlschema
    end

    it { is_expected.to have_css 'th', text: 'Suspension period' }
    it { is_expected.not_to have_css 'th', text: 'Blocking period' }
  end

  context 'with only blocking period' do
    let :quota_definition do
      build :definition, blocking_period_start_date: Date.yesterday.xmlschema,
                         blocking_period_end_date: Date.tomorrow.xmlschema
    end

    it { is_expected.to have_css 'th', text: 'Blocking period' }
    it { is_expected.not_to have_css 'th', text: 'Suspension period' }
  end

  context 'with both blocking and suspension periods' do
    let :quota_definition do
      build :definition, suspension_period_start_date: Date.yesterday.xmlschema,
                         suspension_period_end_date: Date.tomorrow.xmlschema,
                         blocking_period_start_date: Date.yesterday.xmlschema,
                         blocking_period_end_date: Date.tomorrow.xmlschema
    end

    it { is_expected.to have_css 'th', text: 'Suspension period' }
    it { is_expected.to have_css 'th', text: 'Blocking period' }
  end

  context 'when there is a QuotaClosedAndTransferredEvent returned for the definition' do
    let(:quota_definition) { build(:definition, :with_incoming_quota_closed_and_transferred_event) }

    it { is_expected.to have_css '#transferred-balance', text: 'Transferred balance' }
  end

  context 'when there is not a QuotaClosedAndTransferredEvent returned for the definition' do
    let(:definition) { build(:definition, :without_incoming_quota_closed_and_transferred_event) }

    it { is_expected.not_to have_css '#transferred-balance', text: 'Transferred balance' }
  end

  context 'when there is no quota definition and the quota order number is not licenced' do
    let(:order_number) { build(:order_number, :no_definition, :non_licenced) }

    it { is_expected.to have_css '#missing-definition-non-licenced' }
  end

  context 'when there is no quota definition and the quota order number is licenced' do
    let(:order_number) { build(:order_number, :no_definition, :licenced) }

    it { is_expected.to have_css '#missing-definition-licenced' }
  end
end
