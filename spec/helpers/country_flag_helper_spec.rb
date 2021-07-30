require 'spec_helper'

describe CountryFlagHelper, type: :helper do
  describe "#country_flag_emoji" do
    subject { helper.country_flag_emoji(iso_2_code) }

    context "with GB" do
      let(:iso_2_code) { 'GB' }

      it { is_expected.to eql('🇬🇧') }
    end
  end

  describe "#country_flag_tag" do
    subject { helper.country_flag_tag(iso_2_code) }

    context "with GB" do
      let(:iso_2_code) { 'GB' }

      it { is_expected.to have_css('span.country-flag', text: '🇬🇧') }
    end
  end
end
