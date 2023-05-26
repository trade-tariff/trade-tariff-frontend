require 'spec_helper'

RSpec.describe SimplifiedProceduralCodeMeasureHelper, type: :helper do
  describe '#date_range_message' do
    let(:simplified_procedural_code_measure) { build(:simplified_procedural_code_measure) }
    let(:subject) { helper.date_range_message(simplified_procedural_code_measure.validity_start_date, simplified_procedural_code_measure.validity_end_date) }

    it { is_expected.to eql '17 February 2023 to 2 March 2023' }
  end
end
