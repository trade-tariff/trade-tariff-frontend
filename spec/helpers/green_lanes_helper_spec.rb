require 'spec_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers
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

    context 'when no_exemptions is true' do
      before do
        allow(assessments).to receive(:no_cat1_exemptions).and_return(true)
      end

      it 'renders category_assessments_card' do
        helper.render_exemptions_or_no_card(1, assessments)
        expect(helper).to have_received(:render).with('category_assessments_card', category: 1)
      end
    end

    context 'when not all exemptions are met' do
      before do
        allow(assessments).to receive(:cat_1_exemptions_met).and_return([1])
      end

      it 'renders category_assessments_card' do
        helper.render_exemptions_or_no_card(1, assessments)
        expect(helper).to have_received(:render).with('category_assessments_card', category: 1)
      end
    end

    context 'when all exemptions are met' do
      before do
        allow(assessments).to receive(:cat_1_exemptions_met).and_return([1, 2])
      end

      it 'renders exemptions_card' do
        helper.render_exemptions_or_no_card(1, assessments)
        expect(helper).to have_received(:render).with('exemptions_card', category: 1)
      end
    end
  end

  describe '#render_exemptions' do
    let(:assessments) { instance_double('Assessments') }
    let(:category) { '3' }

    before do
      allow(helper).to receive(:render_exemptions_or_no_card)
      allow(helper).to receive(:render_all_exemptions)
    end

    context 'when category is 3' do
      before do
        allow(assessments).to receive(:cat_1_exemptions_met).and_return(cat_1_exemptions_met)
        allow(assessments).to receive(:cat_2_exemptions_met).and_return(cat_2_exemptions_met)
      end

      context 'when cat_1_exemptions_met or cat_2_exemptions_met is true' do
        let(:cat_1_exemptions_met) { true }
        let(:cat_2_exemptions_met) { false }

        it 'renders category all exemptions' do
          helper.render_exemptions(assessments, category)
          expect(helper).to have_received(:render_all_exemptions).with(assessments)
        end
      end

      context 'when both cat_1_exemptions_met and cat_2_exemptions_met are false' do
        let(:cat_1_exemptions_met) { false }
        let(:cat_2_exemptions_met) { false }

        it 'does not render any exemptions', :aggregate_failures do
          helper.render_exemptions(assessments, category)
          expect(helper).not_to have_received(:render_all_exemptions)
          expect(helper.render_exemptions(assessments, category)).to be_nil
        end
      end
    end

    context 'when category is 1' do
      let(:category) { '1' }

      before do
        allow(assessments).to receive(:cat_1_exemptions_met).and_return(cat_1_exemptions_met)
        allow(assessments).to receive(:cat_2_exemptions_met).and_return(cat_2_exemptions_met)
        allow(assessments).to receive(:no_cat1_exemptions).and_return(no_cat1_exemptions)
        allow(assessments).to receive(:cat_1_exemptions_not_met).and_return(cat_1_exemptions_not_met)
      end

      context 'when cat_1_exemptions are not met and cat_2_exemptions_met is false and there are cat1_exemptions' do
        let(:cat_1_exemptions_met) { false }
        let(:cat_2_exemptions_met) { false }
        let(:no_cat1_exemptions) { false }
        let(:cat_1_exemptions_not_met) { true }

        it 'renders exemptions or no card for category 1', :aggregate_failures do
          allow(helper).to receive(:render_exemptions_or_no_card).with(1, assessments).and_return('category_1_exemptions')
          result = helper.render_exemptions(assessments, category)
          expect(helper).to have_received(:render_exemptions_or_no_card).with(1, assessments)
          expect(result).to eq('category_1_exemptions')
        end
      end
    end

    context 'when category is 2' do
      let(:category) { '2' }

      before do
        allow(assessments).to receive(:cat_1_exemptions_met).and_return(cat_1_exemptions_met)
        allow(assessments).to receive(:cat_2_exemptions_met).and_return(cat_2_exemptions_met)
        allow(assessments).to receive(:no_cat1_exemptions).and_return(no_cat1_exemptions)
        allow(assessments).to receive(:cat_1_exemptions_not_met).and_return(cat_1_exemptions_not_met)
      end

      context 'when cat_1_exemptions_met and cat_2_exemptions_met is met and no_cat1_exemptions is false' do
        let(:cat_1_exemptions_met) { true }
        let(:cat_2_exemptions_met) { true }
        let(:no_cat1_exemptions) { false }
        let(:cat_1_exemptions_not_met) { false }

        it 'does render exemptions or no card for both categories', :aggregate_failures do
          allow(helper).to receive(:render_exemptions_or_no_card).with(1, assessments).and_return('category_1_exemptions')
          allow(helper).to receive(:render_exemptions_or_no_card).with(2, assessments).and_return('category_2_exemptions')
          result = helper.render_exemptions(assessments, category)
          expect(helper).to have_received(:render_exemptions_or_no_card).with(1, assessments)
          expect(helper).to have_received(:render_exemptions_or_no_card).with(2, assessments)
          expect(result).to eq('category_1_exemptionscategory_2_exemptions')
        end
      end

      context 'when cat_1_exemptions are met and cat_2_exemptions are not met and no_cat1_exemptions is false' do
        let(:cat_1_exemptions_met) { true }
        let(:cat_2_exemptions_met) { false }
        let(:no_cat1_exemptions) { false }
        let(:cat_1_exemptions_not_met) { false }

        it 'does render exemptions or no card for both categories', :aggregate_failures do
          allow(helper).to receive(:render_exemptions_or_no_card).with(1, assessments).and_return('category_1_exemptions')
          allow(helper).to receive(:render_exemptions_or_no_card).with(2, assessments).and_return('category_2_exemptions')
          result = helper.render_exemptions(assessments, category)
          expect(helper).to have_received(:render_exemptions_or_no_card).with(1, assessments)
          expect(helper).to have_received(:render_exemptions_or_no_card).with(2, assessments)
          expect(result).to eq('category_1_exemptionscategory_2_exemptions')
        end
      end

      context 'when cat_1_exemptions are not met and cat_2_exemptions are not met and no_cat1_exemptions is true' do
        let(:cat_1_exemptions_met) { false }
        let(:cat_2_exemptions_met) { false }
        let(:no_cat1_exemptions) { true }
        let(:cat_1_exemptions_not_met) { true }

        it 'does render exemptions or no card for both categories', :aggregate_failures do
          helper.render_exemptions(assessments, category)
          expect(helper).not_to have_received(:render_exemptions_or_no_card).with(1, assessments)
          expect(helper).not_to have_received(:render_exemptions_or_no_card).with(2, assessments)
          expect(helper.render_exemptions(assessments, 1)).to be_nil
        end
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
