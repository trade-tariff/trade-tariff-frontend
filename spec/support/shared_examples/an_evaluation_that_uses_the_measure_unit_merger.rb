RSpec.shared_examples_for 'an evaluation that uses the measure unit merger' do
  describe '#call' do
    before do
      allow(ApplicableMeasureUnitMerger).to receive(:new).and_call_original
    end

    it 'calls the ApplicableMeasureUnitMerger service to merge units' do
      evaluator.call

      expect(ApplicableMeasureUnitMerger).to have_received(:new)
    end
  end
end
