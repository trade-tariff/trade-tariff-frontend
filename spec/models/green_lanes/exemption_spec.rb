require 'spec_helper'

RSpec.describe GreenLanes::Exemption do
  subject { build :green_lanes_exemption }

  it { is_expected.to respond_to :code }
  it { is_expected.to respond_to :description }
  it { is_expected.to respond_to :formatted_description }
end
