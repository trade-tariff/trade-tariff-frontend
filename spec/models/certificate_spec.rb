require 'spec_helper'

RSpec.describe Certificate do
  describe '.relationships' do
    it { expect(described_class.relationships).to eq(%i[goods_nomenclatures]) }
  end

  describe '#guidance_cds_html' do
    context 'when guidance_cds is present' do
      subject(:certificate) { build(:certificate, :with_guidance) }

      it 'returns rendered HTML' do
        expect(certificate.guidance_cds_html).to include('<p>')
      end

      it 'returns an html_safe string' do
        expect(certificate.guidance_cds_html).to be_html_safe
      end

      it 'memoizes the result' do
        expect(Govspeak::Document).to receive(:new).once.and_call_original

        2.times { certificate.guidance_cds_html }
      end
    end

    context 'when guidance_cds is absent' do
      subject(:certificate) { build(:certificate, guidance_cds: nil) }

      it { expect(certificate.guidance_cds_html).to eq('') }
      it { expect(certificate.guidance_cds_html).to be_html_safe }
    end
  end
end
