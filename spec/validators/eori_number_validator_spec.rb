require 'spec_helper'

RSpec.describe EoriNumberValidator do
  describe '.eori_number?' do
    ['GB123456789', 'gb 123 456 789', 'GB123456789000', 'GB1234567890123', 'XI123456789000', 'xi1234567890123'].each do |term|
      it "treats #{term.inspect} as an EORI number" do
        expect(described_class.eori_number?(term)).to be(true)
      end
    end

    ['GB12345678', 'GB', '8471300000', 'laptop', 'DE123456789', 'GB-123456789000', '', nil].each do |term|
      it "does not treat #{term.inspect} as an EORI number" do
        expect(described_class.eori_number?(term)).to be(false)
      end
    end
  end
end
