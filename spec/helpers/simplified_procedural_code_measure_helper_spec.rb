require 'spec_helper'

RSpec.describe SimplifiedProceduralCodeMeasureHelper, type: :helper do
  describe '#date_range_message' do
    subject(:date_range_message) { helper.date_range_message('2023-02-17', '2023-03-02') }

    it { is_expected.to eql '17 February 2023 to 2 March 2023' }
  end

  describe '#simplified_procedural_code_page_title' do
    subject(:simplified_procedural_code_page_title) { helper.simplified_procedural_code_page_title(by_code, simplified_procedural_code, goods_nomenclature_label) }

    context 'when by_code is false' do
      let(:by_code) { true }
      let(:simplified_procedural_code) { '123' }
      let(:goods_nomenclature_label) { 'Fresh fruit and vegetables' }

      it { is_expected.to eql 'Simplified procedure value rates for code 123 - Fresh fruit and vegetables' }
    end

    context 'when by_code is true' do
      let(:by_code) { false }
      let(:simplified_procedural_code) { nil }
      let(:goods_nomenclature_label) { nil }

      it { is_expected.to eql 'Check simplified procedure value rates for fresh fruit and vegetables' }
    end
  end

  describe '#goods_nomenclature_item_id_links_for' do
    subject(:goods_nomenclature_item_id_links_for) { helper.goods_nomenclature_item_id_links_for(goods_nomenclature_item_ids) }

    let(:goods_nomenclature_item_ids) { '0808100000, 0808200000' }

    it { is_expected.to eql '<a href="/commodities/0808100000">0808100000</a>, <a href="/commodities/0808200000">0808200000</a>' }
    it { is_expected.to be_html_safe }
  end

  describe '#presented_duty_amount' do
    subject(:presented_duty_amount) { helper.presented_duty_amount(simplified_procedural_code_measure) }

    let(:simplified_procedural_code_measure) { build :simplified_procedural_code_measure, duty_amount: }

    context 'when duty_amount is nil' do
      let(:duty_amount) { nil }

      it { is_expected.to eql '—' }
    end

    context 'when duty_amount is present' do
      let(:duty_amount) { 1.2 }

      it { is_expected.to eql '£1.20' }
    end
  end
end
