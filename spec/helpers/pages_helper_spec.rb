require 'spec_helper'

RSpec.describe PagesHelper, type: :helper do
  describe '#cn2021_cn2022_10_digit_files', vcr: { cassette_name: 'chapters' } do
    subject(:cn2021_cn2022_10_digit_files) { helper.cn2021_cn2022_10_digit_files(Chapter.all) }

    let(:expected_file_info) do
      [
        'cn2021_2022/2022 10 digit codes Chapter 03.xlsx',
        '13 KB',
        'Chapter 03 - Fish and crustaceans, molluscs and other aquatic invertebrates (2023 10-digit changes)',
      ]
    end

    it { is_expected.to include(expected_file_info) }
  end

  describe '#cn2021_cn2022_8_digit_file' do
    subject(:cn2021_cn2022_8_digit_file) { helper.cn2021_cn2022_8_digit_file }

    let(:expected_file_info) do
      [
        'cn2021_2022/CorrelationCN2021toCN2022Rev21Oct.xls',
        '127 KB',
        'Download UK Goods classification 2021 to 2022 correlation table (changes to 8-digit commodity codes)',
      ]
    end

    it { is_expected.to eq(expected_file_info) }
  end
end
