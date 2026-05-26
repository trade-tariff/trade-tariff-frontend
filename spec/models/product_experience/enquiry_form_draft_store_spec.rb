require 'spec_helper'

RSpec.describe ProductExperience::EnquiryFormDraftStore, :aggregate_failures do
  let(:redis) { MockRedis.new }

  around do |example|
    old_client = described_class.instance_variable_get(:@client)
    described_class.client = redis
    example.run
  ensure
    described_class.client = old_client
  end

  describe '.read and .write' do
    it 'stores string-keyed enquiry data as JSON outside the browser session' do
      described_class.write('draft-1', category: 'classification', goods_product: 'Embroidery floss')

      expect(described_class.read('draft-1')).to eq(
        'category' => 'classification',
        'goods_product' => 'Embroidery floss',
      )
      expect(JSON.parse(redis.get('product_experience:enquiry_form:draft-1'))).to eq(
        'category' => 'classification',
        'goods_product' => 'Embroidery floss',
      )
    end

    it 'sets a four hour expiry on write' do
      described_class.write('draft-1', category: 'classification')

      expect(redis.ttl('product_experience:enquiry_form:draft-1')).to be_between(
        4.hours.to_i - 1,
        4.hours.to_i,
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
