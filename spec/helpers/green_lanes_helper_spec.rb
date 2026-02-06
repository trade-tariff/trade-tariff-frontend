RSpec.describe GreenLanesHelper, type: :helper do
  before { allow(helper).to receive(:render) }

  describe '#format_pseudo_code_for_exemption' do
    let(:exemption_with_wfe_code) { instance_double(GreenLanes::Exemption, code: 'WFE001', formatted_description: 'Ukraine exemption') }
    let(:exemption_without_wfe_code) { instance_double(GreenLanes::Exemption, code: 'Y171', formatted_description: 'Food Exemption') }

    it 'returns the formatted description for codes starting with WFE' do
      expect(format_pseudo_code_for_exemption(exemption_with_wfe_code)).to eq('Ukraine exemption')
    end

    it 'returns the code and formatted description for codes not starting with WFE' do
      expect(format_pseudo_code_for_exemption(exemption_without_wfe_code)).to eq('Y171 Food Exemption')
    end
  end

  describe '#hide_pseudo_code' do
    it 'returns an empty string for codes starting with WFE' do
      expect(hide_pseudo_code('WFE001')).to eq('')
    end

    it 'returns the original code for codes not starting with WFE' do
      expect(hide_pseudo_code('Y171')).to eq('Y171')
    end
  end

  describe '#render_exemptions_or_no_card' do
    let(:assessments) do
      instance_double(GreenLanes::AssessmentsPresenter,
                      no_cat1_exemptions: false,
                      cat_1_assessments_met: [1],
                      cat_1_assessments: [assessment_1, assessment_2])
    end

    let(:assessment_1) { OpenStruct.new(category_assessment_id: 1) }
    let(:assessment_2) { OpenStruct.new(category_assessment_id: 2) }

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
    let(:assessments) { double }
    let(:result) { '3' }
    let(:cas_without_exemptions) { instance_double(Array, present?: false) }

    before do
      allow(helper).to receive(:render_exemptions_or_no_card)
      helper.instance_variable_set(:@cas_without_exemptions, cas_without_exemptions)
    end

    context 'when result is 3' do
      before do
        allow(assessments).to receive_messages(cat_1_exemptions: [1], cat_2_exemptions: [1])
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
      end

      it 'renders exemptions or no card for category 1 only', :aggregate_failures do
        helper.render_exemptions(assessments, '1')
        expect(helper).to have_received(:render_exemptions_or_no_card).with(1, assessments, '1')
        expect(helper).not_to have_received(:render_exemptions_or_no_card).with(2, assessments, '1')
      end
    end

    context 'when result is 1 and @cas_without_exemptions is present' do
      let(:cas_without_exemptions) { instance_double(Array, present?: true) }

      before do
        allow(assessments).to receive(:cat_1_exemptions).and_return([])
      end

      it 'renders exemptions or no card for category 1 only', :aggregate_failures do
        helper.render_exemptions(assessments, '1')
        expect(helper).to have_received(:render_exemptions_or_no_card).with(1, assessments, '1')
        expect(helper).not_to have_received(:render_exemptions_or_no_card).with(2, assessments, '1')
      end
    end

    context 'when result is 2 and cat_1_exemptions is not empty' do
      before do
        allow(assessments).to receive_messages(cat_1_exemptions: [1], cat_2_exemptions: [])
      end

      it 'renders exemptions or no card for category 1 only', :aggregate_failures do
        helper.render_exemptions(assessments, '2')
        expect(helper).to have_received(:render_exemptions_or_no_card).with(1, assessments, '2')
        expect(helper).not_to have_received(:render_exemptions_or_no_card).with(2, assessments, '2')
      end
    end

    context 'when result is 2 and cat_2_exemptions is not empty' do
      before do
        allow(assessments).to receive_messages(cat_1_exemptions: [], cat_2_exemptions: [1])
      end

      it 'renders exemptions or no card for category 2 only', :aggregate_failures do
        helper.render_exemptions(assessments, '2')
        expect(helper).not_to have_received(:render_exemptions_or_no_card).with(1, assessments, '2')
        expect(helper).to have_received(:render_exemptions_or_no_card).with(2, assessments, '2')
      end
    end

    context 'when result is 2 and @cas_without_exemptions is present' do
      let(:cas_without_exemptions) { instance_double(Array, present?: true) }

      before do
        allow(assessments).to receive_messages(cat_1_exemptions: [1], cat_2_exemptions: [1])
      end

      it 'renders exemptions or no card for both categories', :aggregate_failures do
        helper.render_exemptions(assessments, '2')
        expect(helper).to have_received(:render_exemptions_or_no_card).with(1, assessments, '2')
        expect(helper).to have_received(:render_exemptions_or_no_card).with(2, assessments, '2')
      end
    end

    describe '#exemption_met?' do
      subject(:exemption_met?) { helper.exemption_met?(category_assessment.exemptions.first.code, 2, category_assessment, answers) }

      let(:category_assessment) { build(:category_assessment, :with_exemptions) }

      context 'when there are answers given and the answers include our exemption code' do
        let(:answers) do
          {
            '2' => {
              category_assessment.resource_id => [category_assessment.exemptions.first.code],
            },
          }
        end

        it { is_expected.to be(true) }
      end

      context 'when there are answers given and the answers include none' do
        let(:answers) do
          { '2' => { category_assessment.id => %w[none] } }
        end

        it { is_expected.to be(false) }
      end

      context 'when there are no answers given' do
        let(:answers) { {} }

        it { is_expected.to be(false) }
      end
    end
  end

  describe '#exemption_checkbox_checked?' do
    subject { helper.exemption_checkbox_checked?('category_assessment_1234567890', 'Y922') }

    before do
      allow(helper).to receive(:params).and_return(
        exemptions: {
          'category_assessment_1234567890' => checked_exemptions,
        },
      )
    end

    context 'when the exemption Y922 was checked' do
      let(:checked_exemptions) { ['', 'Y922'] }

      it { is_expected.to be true }
    end

    context 'when the no options was checked' do
      let(:checked_exemptions) { [''] }

      it { is_expected.to be false }
    end
  end

  describe '#exemption_checkbox_none?' do
    subject { helper.exemption_checkbox_none?('category_assessment_1234567890') }

    before do
      allow(helper).to receive(:params)
                        .and_return(
                          exemptions: {
                            'category_assessment_1234567890' => checked_exemptions,
                          },
                        )
    end

    context 'when "none" was checked' do
      let(:checked_exemptions) { ['', 'none'] }

      it { is_expected.to be true }
    end

    context 'when the exemption Y922 is not checked' do
      let(:checked_exemptions) { ['', 'Y922'] }

      it { is_expected.to be false }
    end
  end

  describe '#unique_exemptions' do
    let(:assessment1) { instance_double(GreenLanes::CategoryAssessment, exemptions: [exemption1, exemption2]) }
    let(:assessment2) { instance_double(GreenLanes::CategoryAssessment, exemptions: [exemption3, exemption2]) }
    let(:exemption1) { instance_double(GreenLanes::Exemption, code: 'E001', formatted_description: 'Description 1') }
    let(:exemption2) { instance_double(GreenLanes::Exemption, code: 'E002', formatted_description: 'Description 2') }
    let(:exemption3) { instance_double(GreenLanes::Exemption, code: 'E003', formatted_description: 'Description 3') }

    let(:assessments) { [assessment1, assessment2] }

    it 'returns unique exemptions across assessments' do
      result = helper.unique_exemptions(assessments)

      expect(result).to contain_exactly(
        [exemption1, assessment1],
        [exemption2, assessment1],
        [exemption3, assessment2],
      )
    end

    it 'does not include duplicate exemptions' do
      result = helper.unique_exemptions(assessments)

      expect(result).not_to include([exemption2, assessment2])
    end
  end

  describe '#exemption_status' do
    let(:exemption) { instance_double(GreenLanes::Exemption, code: 'E001') }
    let(:category_assessment) { instance_double(GreenLanes::CategoryAssessment) }
    let(:category) { double }
    let(:answers) { double }

    before do
      assign(:answers, answers) # Mock @answers as an instance variable
    end

    it 'returns "Exemption met" when the exemption is met' do
      allow(helper).to receive(:exemption_met?).with(exemption.code, category, category_assessment, answers).and_return(true)

      expect(helper.exemption_status(exemption, category, category_assessment)).to eq('Exemption met')
    end

    it 'returns "Exemption not met" when the exemption is not met' do
      allow(helper).to receive(:exemption_met?).with(exemption.code, category, category_assessment, answers).and_return(false)

      expect(helper.exemption_status(exemption, category, category_assessment)).to eq('Exemption not met')
    end
  end
end
