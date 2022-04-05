require 'spec_helper'

RSpec.describe MeasureCondition do
  subject(:condition) { build(:measure_condition) }

  describe '#requirement' do
    it { expect(condition.requirement).to be_html_safe }
  end

  describe 'attributes' do
    it {
      expect(condition).to respond_to(:condition,
                                      :document_code,
                                      :action,
                                      :duty_expression,
                                      :certificate_description,
                                      :guidance_cds,
                                      :guidance_chief)
    }
  end
end
