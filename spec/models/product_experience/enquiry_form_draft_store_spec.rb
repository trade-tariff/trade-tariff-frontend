require 'spec_helper'

RSpec.describe ProductExperience::EnquiryFormDraftStore, :aggregate_failures do
  let(:cache_store) { ActiveSupport::Cache::MemoryStore.new }

  around do |example|
    old_cache_store = described_class.instance_variable_get(:@cache_store)
    described_class.cache_store = cache_store
    example.run
  ensure
    described_class.cache_store = old_cache_store
  end

  describe '.read and .write' do
    it 'stores string-keyed enquiry data outside the browser session' do
      described_class.write('draft-1', category: 'classification', goods_product: 'Embroidery floss')

      expect(described_class.read('draft-1')).to eq(
        'category' => 'classification',
        'goods_product' => 'Embroidery floss',
      )
      expect(cache_store.read('product_experience:enquiry_form:draft-1')).to eq(
        'category' => 'classification',
        'goods_product' => 'Embroidery floss',
      )
    end

    it 'sets a four hour expiry on write' do
      allow(cache_store).to receive(:write).and_call_original

      described_class.write('draft-1', category: 'classification')

      expect(cache_store).to have_received(:write).with(
        'product_experience:enquiry_form:draft-1',
        { 'category' => 'classification' },
        expires_in: 4.hours,
      )
    end

    it 'can distinguish an intentionally empty draft from a missing draft' do
      described_class.write('draft-1', {})

      expect(described_class.read('draft-1')).to eq({})
      expect(described_class.read('missing-draft')).to be_nil
    end
  end

  describe '.exists?' do
    it 'returns true only when the draft key exists' do
      described_class.write('draft-1', category: 'classification')

      expect(described_class.exists?('draft-1')).to be(true)
      expect(described_class.exists?('missing-draft')).to be(false)
    end
  end

  describe '.delete' do
    it 'removes the draft' do
      described_class.write('draft-1', category: 'classification')

      described_class.delete('draft-1')

      expect(described_class.read('draft-1')).to be_nil
    end
  end
end
