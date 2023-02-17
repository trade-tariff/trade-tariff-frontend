require 'spec_helper'

RSpec.describe CountryFlagHelper, type: :helper do
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

    context "with country which we don't have a flag for" do
      subject(:rendered) { helper.country_flag_tag('A1') }

      it('returns nothing') { is_expected.to be_nil }
    end

    context "with country which we don't have a flag which is in ignore list" do
      subject(:rendered) { helper.country_flag_tag('XI') }

      it('returns nothing') { is_expected.to be_nil }
    end
  end
end
