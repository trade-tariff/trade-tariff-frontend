require 'spec_helper'

RSpec.describe GeographicalArea do
  describe '.relationships' do
    it { expect(described_class.relationships).to eq([:children_geographical_areas]) }
  end

  describe '.all', vcr: { cassette_name: 'geographical_areas#countries' } do
    subject(:countries) { described_class.all }

    it 'fetches geographical areas that are countries from the API' do
      expected_countries = %w[
        AD AE AF AG AI AL AM AO AQ AR AS
        AT AU AW AX AZ BA BB BD BE BF BG
        BH BI BJ BL BM BN BO BQ BR BS BT
        BV BW BY BZ CA CC CD CF CG CH CI
        CK CL CM CN CO CR CU CV CW CX CY
        CZ DE DJ DK DM DO DZ EC EE EG EH
        ER ES ET FI FJ FK FM FO FR GA GD
        GE GF GH GI GL GM GN GP GQ GR GS
        GT GU GW GY HK HM HN HR HT HU ID
        IE IL IM IN IO IQ IR IS IT JM JO
        JP KE KG KH KI KM KN KP KR KW KY
        KZ LA LB LC LI LK LR LS LT LU LV
        LY MA MC MD ME MF MG MH MK ML MM
        MN MO MP MQ MR MS MT MU MV MW MX
        MY MZ NA NC NE NF NG NI NL NO NP
        NR NU NZ OM PA PE PF PG PH PK PL
        PM PN PR PS PT PW PY QA RE RO RU
        RW SA SB SC SD SE SG SH SI SJ SK
        SL SM SN SO SR SS ST SV SX SY SZ
        TC TD TF TG TH TJ TK TL TM TN TO
        TR TT TV TW TZ UA UG UM US UY UZ
        VA VC VE VG VI VN VU WF WS XC XK
        XL XS YE YT ZA ZB ZD ZE ZF ZG ZH
        ZM ZN ZU ZW
      ]
      expect(countries.map(&:id)).to eq(expected_countries)
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

  describe '.european_union', vcr: { cassette_name: 'geographical_areas#1013' } do
    subject(:european_union) { described_class.european_union }

    it { is_expected.to have_attributes(id: '1013', geographical_area_id: '1013', description: 'European Union') }
  end

  describe '.european_union_members', vcr: { cassette_name: 'geographical_areas#1013' } do
    subject(:european_union_members) { described_class.european_union_members }

    it { expect(european_union_members.count).to eq(28) }
  end

  describe '.eu_member_ids', vcr: { cassette_name: 'geographical_areas#1013' } do
    subject(:eu_member_ids) { described_class.eu_members_ids }

    let(:expected_countries) do
      %w[AT BE BG CY CZ DE DK EE ES FI FR GR HR HU IE IT LT LU LV MT NL PL PT RO SE SI SK]
    end

    it { is_expected.to eq(expected_countries) }
  end

  describe '.country_options',
           vcr: { cassette_name: 'geographical_areas#countries' } do
    subject(:country_options) { described_class.country_options }

    let(:expected_countries) do
      countries = file_fixture('geographical_areas/countries.json').read

      sorted_countries = JSON.parse(countries).sort_by { |country| country[0] }

      [['All countries', ' ']] + sorted_countries
    end

    it 'returns countries in alphabetical order with "All countries" first' do
      expect(country_options).to eq(expected_countries)
    end
  end

  describe '#eu_member?', vcr: { cassette_name: 'geographical_areas#1013' } do
    subject(:geographical_area) { build(:geographical_area, id: geographical_area_id) }

    context 'when the country is part of EU' do
      let(:geographical_area_id) { 'IT' } # Italy

      it { is_expected.to be_eu_member }
    end

    context 'when the area is the eu referencing country' do
      let(:geographical_area_id) { 'EU' } # European Union

      it { is_expected.to be_eu_member }
    end

    context 'when the country is NOT part of EU' do
      let(:geographical_area_id) { 'AF' } # Afghanistan

      it { is_expected.not_to be_eu_member }
    end
  end

  describe '#channel_islands?' do
    subject(:geographical_area) { build(:geographical_area, id:) }

    context 'when the geographical area is the Channel Islands' do
      let(:id) { '1080' }

      it { is_expected.to be_channel_islands }
    end

    context 'when the geographical area is NOT the Channel Islands' do
      let(:id) { '1013' }

      it { is_expected.not_to be_channel_islands }
    end
  end
end
