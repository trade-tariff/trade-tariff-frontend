require 'spec_helper'

RSpec.describe GreenLanes::Exemption do
  subject { build :green_lanes_exemption }

  it { is_expected.to respond_to :code }
  it { is_expected.to respond_to :description }
  it { is_expected.to respond_to :formatted_description }

  describe '#display_code' do
    context "when the code starts with 'WFE'" do
      it 'returns an empty string' do
        exemption = described_class.new(code: 'WFE123')
        expect(exemption.display_code).to eq('')
      end
    end

    context "when the code does not start with 'WFE'" do
      it 'returns the original code' do
        exemption = described_class.new(code: 'Y123')
        expect(exemption.display_code).to eq('Y123')
      end
    end
  end
end
