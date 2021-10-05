require 'spec_helper'

RSpec.describe MeasureCondition do
  subject(:condition) { build(:measure_condition) }

  describe '#requirement' do
    it { expect(condition.requirement).to be_html_safe }
  end
end
