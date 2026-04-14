require 'spec_helper'

RSpec.describe Certificate do
  describe '.relationships' do
    it { expect(described_class.relationships).to eq(%i[goods_nomenclatures]) }
  end

  describe '#guidance_cds_html' do
    context 'when guidance_cds is a plain string' do
      subject(:certificate) { build(:certificate, :with_guidance) }

      it 'returns an HTML-safe string' do
        expect(certificate.guidance_cds_html).to be_html_safe
      end

      it 'returns a non-empty string' do
        expect(certificate.guidance_cds_html).to be_present
      end

      it 'memoizes the result so the same object is returned on repeated calls' do
        first_call = certificate.guidance_cds_html
        expect(certificate.guidance_cds_html).to equal(first_call)
      end
    end

    context 'when guidance_cds is nil' do
      subject(:certificate) { build(:certificate, guidance_cds: nil) }

      it 'returns an empty string' do
        expect(certificate.guidance_cds_html).to eq('')
      end

      it 'returns an html-safe string' do
        expect(certificate.guidance_cds_html).to be_html_safe
      end
    end

    context 'when guidance_cds is a Hash with a content key' do
      subject(:certificate) { build(:certificate, guidance_cds: { 'content' => 'Some **bold** text' }) }

      it 'extracts the content and returns an HTML string' do
        expect(certificate.guidance_cds_html).to include('<strong>')
      end

      it 'memoizes the result so the same object is returned on repeated calls' do
        first_call = certificate.guidance_cds_html
        expect(certificate.guidance_cds_html).to equal(first_call)
      end
    end
  end
end
