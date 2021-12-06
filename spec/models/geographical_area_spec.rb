require 'spec_helper'

RSpec.describe GeographicalArea do
  describe '.all', vcr: { cassette_name: 'geographical_areas#countries' } do
    subject(:countries) { described_class.all }

    it 'fetches geographical areas that are countries from the API' do
      expected_countries = %w[
        SA BB SB BD SC SD BE SE BF SG BG SH BH SI SK BI SL BJ SM SN BM BN SO BO BR
        SR BS ST BT SV HM NF PS TF TK UM CK NU XK QU QV QW QX QY QZ QR WS GS GU TL
        XS EU CI ME AD NI NL NO NP NR AE NZ OM PA AF PE PF AG PG AI PH AL PK PL AM
        PM PN PT AR PY AT QA RO AU RU AW RW AZ BA GN GQ GT GW GY HK HN HR HT HU ID
        IE IL IN IO IQ IR IS IT JM JO JP KE KG KH KI KM KN KP KR KW KY KZ LA LB LC
        LK LR LS LT LU LV LY MA MD MG MH ML MN MO MR MT MU MV MW MX MY MZ NA NC NE
        NG AO GD ER LI PW MS MK MP GR CD XL MM SY SZ BW TC BY TD BZ TG CA TH CF CG
        CH TJ TM TN CL TO CM TR CN TT CO TV CR TW TZ UA CU UG US CV UY CY UZ CZ VA
        VC VE VG DE DJ DK VI DM DO VN VU DZ WF EC EE EG XC ES ET FI FJ FK FM FO FR
        GA GB YE ZA ZM ZW GE GH GI GL GM QS QQ AQ AS BV CC CX BL BQ CW SS SX EH QP
      ]

      expect(countries.map(&:id)).to eq(expected_countries)
    end
  end

  describe '.by_long_description', vcr: { cassette_name: 'geographical_areas#countries' } do
    subject(:by_long_desc) { described_class.by_long_description('Ind') }

    it 'returns the correct presented geographical areas' do
      expected_geographical_areas = [
        { id: 'ID', text: 'Indonesia (ID)' },
        { id: 'IN', text: 'India (IN)' },
        { id: 'IO', text: 'British Indian Ocean Territory (IO)' },
      ]

      expect(by_long_desc).to eq(expected_geographical_areas)
    end
  end

  describe '#erga_omnes?' do
    context 'when the geographical area is the world' do
      subject(:geographical_area) { build(:geographical_area, :erga_omnes) }

      it { is_expected.to be_erga_omnes }
    end

    context 'when the geographical area is not the world' do
      subject(:geographical_area) { build(:geographical_area) }

      it { is_expected.not_to be_erga_omnes }
    end
  end

  describe '#eu_member?', vcr: { cassette_name: 'geographical_areas#1013' } do
    subject(:geographical_area) { build(:geographical_area, id: geographical_area_id) }

    context 'when the country is part of EU' do
      let(:geographical_area_id) { 'IT' } # Italy

      it { is_expected.to be_eu_member }
    end

    context 'when the country is NOT part of EU' do
      let(:geographical_area_id) { 'AF' } # Afghanistan

      it { is_expected.not_to be_eu_member }
    end
  end
end
