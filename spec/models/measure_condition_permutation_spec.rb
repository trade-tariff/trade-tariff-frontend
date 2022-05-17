require 'spec_helper'

RSpec.describe MeasureConditionPermutation do
  it { is_expected.to respond_to :measure_conditions }
  it { is_expected.to have_attributes measure_conditions: instance_of(Array) }
  it { is_expected.to have_attributes relationships: include(:measure_conditions) }
end
