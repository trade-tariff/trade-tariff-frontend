require 'spec_helper'

RSpec.describe ProductExperience::EnquiryFormDraftStore do
  around do |example|
    old_store = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    example.run
  ensure
    Rails.cache = old_store
  end

  describe '.read and .write' do
    it 'stores string-keyed enquiry data outside the browser session' do
      described_class.write('draft-1', category: 'classification', goods_product: 'Embroidery floss')

      expect(described_class.read('draft-1')).to eq(
        'category' => 'classification',
        'goods_product' => 'Embroidery floss',
      )
    end

    it 'returns an empty hash when the draft is missing' do
      expect(described_class.read('missing-draft')).to eq({})
    end
  end

  describe '.delete' do
    it 'removes the draft' do
      described_class.write('draft-1', category: 'classification')

      described_class.delete('draft-1')

      expect(described_class.read('draft-1')).to eq({})
    end
  end
end
