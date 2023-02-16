require 'spec_helper'

RSpec.describe ImageGuidesHelper, type: :helper do
  describe '#image_for_guide' do
    context 'when image for the guides does exist' do
      subject(:rendered) { helper.image_for_guide('rice.png') }

      it 'includes the relevant image' do
        expect(rendered).to \
          have_css('img.image-guide[src*="media/images/guides/rice"]')
      end
    end

    context 'with alt text' do
      subject(:rendered) { helper.image_for_guide('rice.png', alt: 'alt text') }

      it 'includes the alt text' do
        expect(rendered).to have_css('img.image-guide[alt="alt text"]')
      end
    end

    context 'when the image for the guide does NOT exist' do
      subject(:rendered) { helper.image_for_guide('non-existent-guide') }

      it('returns nothing') { is_expected.to be_nil }
    end
  end
end
