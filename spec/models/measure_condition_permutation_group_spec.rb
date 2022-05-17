require 'spec_helper'

RSpec.describe MeasureConditionPermutationGroup do
  it { is_expected.to respond_to :condition_code }
  it { is_expected.to respond_to :permutations }
  it { is_expected.to have_attributes permutations: instance_of(Array) }
  it { is_expected.to have_attributes relationships: include(:permutations) }
end
