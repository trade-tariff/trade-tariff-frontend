require 'spec_helper'

RSpec.describe GreenLanes::Theme do
  subject(:theme) { build :green_lanes_theme }

  it { is_expected.to respond_to :section }
  it { is_expected.to respond_to :theme }
  it { is_expected.to respond_to :category }

  describe 'attributes' do
    it { is_expected.to have_attributes to_s: "#{theme.section} #{theme.theme}" }
  end
end
