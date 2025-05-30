RSpec.shared_examples_for 'an evaluation that uses the measure unit merger' do
  describe '#call' do
    before do
      allow(DutyCalculator::ApplicableMeasureUnitMerger).to receive(:new).and_call_original
    end

    it 'calls the DutyCalculator::ApplicableMeasureUnitMerger service to merge units' do
      evaluator.call

      expect(DutyCalculator::ApplicableMeasureUnitMerger).to have_received(:new)
    end
  end
end
