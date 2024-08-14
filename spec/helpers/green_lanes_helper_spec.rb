require 'spec_helper'

RSpec.describe GreenLanesHelper, type: :helper do
  let(:assessments) { instance_double('Assessments', cat_1_exemptions_met: true, cat_2_exemptions_met: true, no_cat1_exemptions: false, cat_1_exemptions_not_met: false) }

  before do
    allow(helper).to receive(:params).and_return(params)
  end

  describe '#render_exemptions_or_no_card' do
    let(:assessments) { instance_double('Assessments', no_cat1_exemptions: false, cat_1_exemptions_met: [1], cat_1_exemptions: [1, 2]) }

    before do
      allow(helper).to receive(:render) # Stub the render method
    end

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

    context 'when not all exemptions are met' do
      before do
        allow(assessments).to receive(:cat_1_exemptions_met).and_return([1])
      end

      it 'renders category_assessments_card' do
        helper.render_exemptions_or_no_card(1, assessments, '1')
        expect(helper).to have_received(:render).with('category_assessments_card', category: 1)
      end
    end

    context 'when all exemptions are met' do
      before do
        allow(assessments).to receive(:cat_1_exemptions_met).and_return([1, 2])
      end

      it 'renders exemptions_card' do
        helper.render_exemptions_or_no_card(1, assessments, '1')
        expect(helper).to have_received(:render).with('exemptions_card', category: 1)
      end
    end
  end

  describe '#render_exemptions' do
    let(:assessments) { instance_double('Assessments') }
    let(:category) { '3' }

    before do
      allow(helper).to receive(:render_exemptions_or_no_card)
    end

    context 'when result is 3' do
      before do
        allow(assessments).to receive(:cat_1_exemptions_met).and_return([1])
        allow(assessments).to receive(:cat_2_exemptions_met).and_return([1])
      end

      it 'renders exemptions or no card for category 1 and 2', :aggregate_failures do
        helper.render_exemptions(assessments, category)
        expect(helper).to have_received(:render_exemptions_or_no_card).with(1, assessments, '3')
        expect(helper).to have_received(:render_exemptions_or_no_card).with(2, assessments, '3')
      end
    end

    context 'when result is not 3 and cat_1_exemptions_met is not empty' do
      before do
        allow(assessments).to receive(:cat_1_exemptions_met).and_return([1])
        allow(assessments).to receive(:cat_2_exemptions_met).and_return([])
      end

      it 'renders exemptions or no card for category 1 only', :aggregate_failures do
        helper.render_exemptions(assessments, '1')
        expect(helper).to have_received(:render_exemptions_or_no_card).with(1, assessments, '1')
        expect(helper).not_to have_received(:render_exemptions_or_no_card).with(2, assessments, '1')
      end
    end

    context 'when result is not 3 and cat_2_exemptions_met is not empty' do
      before do
        allow(assessments).to receive(:cat_1_exemptions_met).and_return([])
        allow(assessments).to receive(:cat_2_exemptions_met).and_return([1])
      end

      it 'renders exemptions or no card for category 2 only', :aggregate_failures do
        helper.render_exemptions(assessments, '1')
        expect(helper).not_to have_received(:render_exemptions_or_no_card).with(1, assessments, '1')
        expect(helper).to have_received(:render_exemptions_or_no_card).with(2, assessments, '1')
      end
    end
  end
end
