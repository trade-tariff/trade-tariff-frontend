require 'spec_helper'

RSpec.describe MeasureCondition do
  subject(:condition) { build(:measure_condition) }

  it { is_expected.to respond_to :condition_code }
  it { is_expected.to respond_to :condition }
  it { is_expected.to respond_to :document_code }
  it { is_expected.to respond_to :action }
  it { is_expected.to respond_to :duty_expression }
  it { is_expected.to respond_to :certificate_description }
  it { is_expected.to respond_to :measure_condition_class }
  it { is_expected.to respond_to :threshold_unit_type }
  it { is_expected.to respond_to :requirement_operator }

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

  describe '#guidance_cds_html' do
    context 'when guidance_cds is a plain string' do
      subject(:condition) { build(:measure_condition, :with_guidance) }

      it 'returns an HTML-safe string' do
        expect(condition.guidance_cds_html).to be_html_safe
      end

      it 'returns a non-empty string' do
        expect(condition.guidance_cds_html).to be_present
      end

      it 'memoizes the result so the same object is returned on repeated calls' do
        first_call = condition.guidance_cds_html
        expect(condition.guidance_cds_html).to equal(first_call)
      end
    end

    context 'when guidance_cds is nil' do
      subject(:condition) { build(:measure_condition) }

      it 'returns an empty string' do
        expect(condition.guidance_cds_html).to eq('')
      end

      it 'returns an html-safe string' do
        expect(condition.guidance_cds_html).to be_html_safe
      end
    end

    context 'when guidance_cds is a Hash with a content key' do
      subject(:condition) { build(:measure_condition, guidance_cds: { 'content' => 'Some **bold** text' }) }

      it 'extracts the content and returns an HTML string' do
        expect(condition.guidance_cds_html).to include('<strong>')
      end

      it 'memoizes the result so the same object is returned on repeated calls' do
        first_call = condition.guidance_cds_html
        expect(condition.guidance_cds_html).to equal(first_call)
      end
    end
  end

  describe '#measure_condition_class' do
    subject { condition.measure_condition_class }

    let :condition do
      build :measure_condition, measure_condition_class: condition_class
    end

    context 'with nil class' do
      let(:condition_class) { nil }

      it { is_expected.to eql '' }
      it { is_expected.to respond_to :threshold? }
      it { is_expected.to respond_to :document? }
      it { is_expected.to have_attributes 'threshold?': false }
      it { is_expected.to have_attributes 'document?': false }
    end

    context 'with document_class' do
      let(:condition_class) { 'document' }

      it { is_expected.to eql 'document' }
      it { is_expected.to respond_to :threshold? }
      it { is_expected.to respond_to :document? }
      it { is_expected.to have_attributes 'threshold?': false }
      it { is_expected.to have_attributes 'document?': true }
    end
  end

  describe '#requirement_text' do
    context 'when the certificate_description is present' do
      subject(:requirement_text) do
        build(
          :measure_condition,
          requirement: nil,
          certificate_description: 'ICCAT swordfish statistical document',
        ).requirement_text
      end

      it { is_expected.to eq('ICCAT swordfish statistical document') }
      it { is_expected.to be_html_safe }
    end

    context 'when the requirement is present' do
      subject(:requirement_text) do
        build(
          :measure_condition,
          requirement: 'Other certificates: ICCAT swordfish statistical document',
          certificate_description: nil,
        ).requirement_text
      end

      it { is_expected.to eq('Other certificates: ICCAT swordfish statistical document') }
      it { is_expected.to be_html_safe }
    end

    context 'when neither the certificate_description or requirement are present' do
      subject(:requirement_text) do
        build(
          :measure_condition,
          requirement: nil,
          certificate_description: nil,
        ).requirement_text
      end

      it { is_expected.to eq('') }
      it { is_expected.to be_html_safe }
    end
  end

  describe '#guidance_cds_html' do
    context 'when guidance_cds is present' do
      subject(:condition) { build(:measure_condition, :with_guidance) }

      it 'returns rendered HTML' do
        expect(condition.guidance_cds_html).to include('<p>')
      end

      it 'returns an html_safe string' do
        expect(condition.guidance_cds_html).to be_html_safe
      end

      it 'memoizes the result' do
        expect(Govspeak::Document).to receive(:new).once.and_call_original

        2.times { condition.guidance_cds_html }
      end
    end

    context 'when guidance_cds is absent' do
      subject(:condition) { build(:measure_condition, guidance_cds: nil) }

      it { expect(condition.guidance_cds_html).to eq('') }
      it { expect(condition.guidance_cds_html).to be_html_safe }
    end
  end

  describe '#presented_action' do
    context 'when action_code is 01' do
      subject(:presented_action) { build(:measure_condition, action_code: '01').presented_action }

      it { is_expected.to eq('Apply the duty') }
    end

    context 'when action_code is not 01' do
      subject(:presented_action) { build(:measure_condition, action_code: '02').presented_action }

      it { is_expected.not_to eq('Apply the duty') }
    end
  end
end
