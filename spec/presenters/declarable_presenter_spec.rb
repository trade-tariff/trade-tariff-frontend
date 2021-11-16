require 'spec_helper'

RSpec.describe DeclarablePresenter do
  subject(:presenter) { described_class.new(declarable) }

  let(:declarable) { Commodity.new(goods_nomenclature_item_id: '0102210000', formatted_description: 'Fruits &mdash') }

  describe '#heading_code' do
    it { expect(presenter.heading_code).to eq('02') }
  end

  describe '#to_s' do
    it { expect(presenter.to_s).to be_html_safe }
    it { expect(presenter.to_s).to eq('Fruits &mdash') }
  end
end
