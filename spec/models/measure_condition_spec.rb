require 'spec_helper'

RSpec.describe MeasureCondition do
  subject(:condition) { build(:measure_condition) }

  describe '#requirement' do
    it { expect(condition.requirement).to be_html_safe }
  end

  it_behaves_like 'a resource that has attributes',
                  condition_code: 'B',
                  condition: 'B: Presentation of a certificate/licence/document',
                  document_code: 'A000',
                  action: 'The entry into free circulation is not allowed',
                  duty_expression: '',
                  certificate_description: 'Foo bar',
                  guidance_cds: 'CDS guiance',
                  guidance_chief: 'CHIEF guiance',
                  requirement: 'requirement'

  describe '#has_guidance?' do
    context 'when the condition has guidance' do
      subject(:condition) { build(:measure_condition, :with_guidance) }

      it { is_expected.to have_guidance }
    end

    context 'when the condition does not have guidance' do
      subject(:condition) { build(:measure_condition) }

      it { is_expected.not_to have_guidance }
    end
  end
end
