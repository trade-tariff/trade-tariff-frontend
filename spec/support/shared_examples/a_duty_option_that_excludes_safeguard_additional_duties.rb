RSpec.shared_examples_for 'a duty option that excludes safeguard additional duties' do
  describe '#excludes?' do
    subject(:excludes?) { described_class.excludes?(additional_duty_option) }

    context 'when the additional duty option is excluded' do
      let(:additional_duty_option) { DutyOptions::AdditionalDuty::AdditionalDutiesSafeguard }

      it { is_expected.to be(true) }
    end

    context 'when the additional duty option is not excluded' do
      let(:additional_duty_option) { DutyOptions::AdditionalDuty::AdditionalDuties }

      it { is_expected.to be(false) }
    end
  end
end
