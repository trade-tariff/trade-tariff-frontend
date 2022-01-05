require 'spec_helper'

RSpec.describe AdditionalCodeSearchForm, type: :model do
  describe '#additional_code_types',
           vcr: { cassette_name: 'search#additional_code_search' } do
    subject { described_class.new({}).additional_code_types.values }

    it { is_expected.to include('2') }
    it { is_expected.not_to include('6') }
    it { is_expected.not_to include('7') }
    it { is_expected.not_to include('9') }
    it { is_expected.not_to include('D') }
    it { is_expected.not_to include('F') }
    it { is_expected.not_to include('P') }
  end
end
