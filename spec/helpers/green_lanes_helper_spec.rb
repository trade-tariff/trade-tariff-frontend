require 'spec_helper'

RSpec.describe GreenLanesHelper, type: :helper do
  let(:assessment_1) { OpenStruct.new(category_assessment_id: 1) }
  let(:assessment_2) { OpenStruct.new(category_assessment_id: 2) }

  let(:assessments) do
    instance_double('Assessments',
                    no_cat1_exemptions: false,
                    cat_1_assessments_met: [1],
                    cat_1_assessments: [assessment_1, assessment_2])
  end

  before do
    allow(helper).to receive(:render)
  end

  describe '#render_exemptions_or_no_card' do
    context 'when result is "3"' do
      it 'renders exemptions_card' do
        helper.render_exemptions_or_no_card(1, assessments, '3')
        expect(helper).to have_received(:render).with('exemptions_card', category: 1)
      end
    end

    context 'when no_exemptions is true' do
      before do
        allow(assessments).to receive(:no_cat1_exemptions).and_return(true)
      end

      it 'renders category_assessments_card' do
        helper.render_exemptions_or_no_card(1, assessments, '1')
        expect(helper).to have_received(:render).with('category_assessments_card', category: 1)
      end
    end

    context 'when not all assessments are met' do
      before do
        allow(assessments).to receive(:cat_1_assessments_met).and_return([1])
      end

      it 'renders category_assessments_card' do
        helper.render_exemptions_or_no_card(1, assessments, '1')
        expect(helper).to have_received(:render).with('category_assessments_card', category: 1)
      end
    end

    context 'when all assessments are met' do
      before do
        allow(assessments).to receive(:cat_1_assessments_met).and_return([1, 2])
      end

      it 'renders exemptions_card' do
        helper.render_exemptions_or_no_card(1, assessments, '1')
        expect(helper).to have_received(:render).with('exemptions_card', category: 1)
      end
    end
  end

  describe '#render_exemptions' do
    let(:assessments) { instance_double('Assessments') }
    let(:result) { '3' }

    before do
      allow(helper).to receive(:render_exemptions_or_no_card)
    end

    # rubocop:disable RSpec/InstanceVariable
    context 'when result is 3' do
      before do
        allow(assessments).to receive(:cat_1_exemptions).and_return([1])
        allow(assessments).to receive(:cat_2_exemptions).and_return([1])
        allow(@cas_without_exemptions).to receive(:present?).and_return(false)
      end

      it 'renders exemptions or no card for category 1 and 2', :aggregate_failures do
        helper.render_exemptions(assessments, result)
        expect(helper).to have_received(:render_exemptions_or_no_card).with(1, assessments, '3')
        expect(helper).to have_received(:render_exemptions_or_no_card).with(2, assessments, '3')
      end
    end

    context 'when result is 1 and cat_1_exemptions is not empty' do
      before do
        allow(assessments).to receive(:cat_1_exemptions).and_return([1])
        allow(@cas_without_exemptions).to receive(:present?).and_return(false)
      end

      it 'renders exemptions or no card for category 1 only', :aggregate_failures do
        helper.render_exemptions(assessments, '1')
        expect(helper).to have_received(:render_exemptions_or_no_card).with(1, assessments, '1')
        expect(helper).not_to have_received(:render_exemptions_or_no_card).with(2, assessments, '1')
      end
    end

    context 'when result is 1 and @cas_without_exemptions is present' do
      before do
        allow(assessments).to receive(:cat_1_exemptions).and_return([])
        allow(@cas_without_exemptions).to receive(:present?).and_return(true)
      end

      it 'renders exemptions or no card for category 1 only', :aggregate_failures do
        helper.render_exemptions(assessments, '1')
        expect(helper).to have_received(:render_exemptions_or_no_card).with(1, assessments, '1')
        expect(helper).not_to have_received(:render_exemptions_or_no_card).with(2, assessments, '1')
      end
    end

    context 'when result is 2 and cat_1_exemptions is not empty' do
      before do
        allow(assessments).to receive(:cat_1_exemptions).and_return([1])
        allow(assessments).to receive(:cat_2_exemptions).and_return([])
        allow(@cas_without_exemptions).to receive(:present?).and_return(false)
      end

      it 'renders exemptions or no card for category 1 only', :aggregate_failures do
        helper.render_exemptions(assessments, '2')
        expect(helper).to have_received(:render_exemptions_or_no_card).with(1, assessments, '2')
        expect(helper).not_to have_received(:render_exemptions_or_no_card).with(2, assessments, '2')
      end
    end

    context 'when result is 2 and cat_2_exemptions is not empty' do
      before do
        allow(assessments).to receive(:cat_1_exemptions).and_return([])
        allow(assessments).to receive(:cat_2_exemptions).and_return([1])
        allow(@cas_without_exemptions).to receive(:present?).and_return(false)
      end

      it 'renders exemptions or no card for category 2 only', :aggregate_failures do
        helper.render_exemptions(assessments, '2')
        expect(helper).not_to have_received(:render_exemptions_or_no_card).with(1, assessments, '2')
        expect(helper).to have_received(:render_exemptions_or_no_card).with(2, assessments, '2')
      end
    end

    context 'when result is 2 and @cas_without_exemptions is present' do
      before do
        allow(assessments).to receive(:cat_1_exemptions).and_return([1])
        allow(assessments).to receive(:cat_2_exemptions).and_return([1])
        allow(@cas_without_exemptions).to receive(:present?).and_return(true)
      end

      it 'renders exemptions or no card for both categories', :aggregate_failures do
        helper.render_exemptions(assessments, '2')
        expect(helper).to have_received(:render_exemptions_or_no_card).with(1, assessments, '2')
        expect(helper).to have_received(:render_exemptions_or_no_card).with(2, assessments, '2')
      end
    end

    describe '#green_lanes_eligibility_start_path' do
      it { expect(helper.green_lanes_eligibility_start_path).to eq('/green_lanes/start/new') }
    end

    # rubocop:enable RSpec/InstanceVariable
  end
end
