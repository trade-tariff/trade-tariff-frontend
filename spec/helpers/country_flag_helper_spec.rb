require 'spec_helper'

describe CountryFlagHelper, type: :helper do
  describe '#country_flag_tag' do
    context 'with GB' do
      subject(:rendered) { helper.country_flag_tag('GB') }

      it 'will include the relevant flag' do
        expect(rendered).to \
          have_css('img.country-flag[src*="media/images/flags/gb"]')
      end
    end

    context 'with alt text' do
      subject :rendered do
        helper.country_flag_tag('GB', alt: 'alt text')
      end

      it 'will include the alt text' do
        expect(rendered).to \
          have_css('img.country-flag[alt="alt text"]')
      end
    end
  end
end
