require 'spec_helper'

describe CountryFlagHelper, type: :helper do
  describe '#country_flag_emoji' do
    subject { helper.country_flag_emoji(two_letter_country_code) }

    context 'with GB' do
      let(:two_letter_country_code) { 'GB' }

      it { is_expected.to eql('🇬🇧') }
    end

    context 'with non country code' do
      let(:two_letter_country_code) { '2300' }

      it { is_expected.to be_nil }
    end
  end

  describe '#country_flag_tag' do
    subject { helper.country_flag_tag(two_letter_country_code) }

    context 'with GB' do
      let(:two_letter_country_code) { 'GB' }

      it { is_expected.to have_css('span.country-flag', text: '🇬🇧') }
    end

    context 'with non country code' do
      let(:two_letter_country_code) { '2300' }

      it { is_expected.to be_nil }
    end
  end
end
