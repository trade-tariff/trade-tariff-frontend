require 'spec_helper'

RSpec.describe ImageGuidesHelper, type: :helper do
  describe '#image_for_guide' do
    before { allow(Sentry).to receive(:capture_message).and_return(true) }

    context 'when image for the guides does exist' do
      subject(:rendered) { helper.image_for_guide('audio') }

      it 'includes the relevant image' do
        expect(rendered).to \
          have_css('img.image-guide[src*="media/images/guides/audio"]')
      end
    end

    context 'with alt text' do
      subject(:rendered) { helper.image_for_guide('audio', alt: 'alt text') }

      it 'includes the alt text' do
        expect(rendered).to have_css('img.image-guide[alt="alt text"]')
      end
    end

    context 'when the image for the guide does NOT exist' do
      subject(:rendered) { helper.country_flag_tag('non-existent-guide') }

      it('returns nothing') { is_expected.to be_nil }

      it 'notifies Sentry' do
        rendered

        expect(Sentry).to have_received(:capture_message)
      end
    end
  end
end
