require 'spec_helper'

describe CountryFlagHelper, type: :helper do
  describe "#country_flag" do
    subject { helper.country_flag(iso_2_code) }

    context "with GB" do
      let(:iso_2_code) { 'GB' }

      it { is_expected.to eql('🇬🇧') }
    end
  end
end
