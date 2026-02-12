require 'spec_helper'

RSpec.describe Myott::StopPressPreferenceForm, type: :model do
  describe 'validations' do
    context 'when preference is blank' do
      subject(:form) { described_class.new(preference: '') }

      before { form.valid? }

      it { is_expected.not_to be_valid }
      it { expect(form.errors[:preference]).to include('Select a subscription preference to continue') }
    end

    context 'when preference is nil' do
      subject(:form) { described_class.new(preference: nil) }

      before { form.valid? }

      it { is_expected.not_to be_valid }
      it { expect(form.errors[:preference]).to include('Select a subscription preference to continue') }
    end

    context 'when preference is invalid' do
      subject(:form) { described_class.new(preference: 'invalid') }

      before { form.valid? }

      it { is_expected.not_to be_valid }
      it { expect(form.errors[:preference]).to include('Select a subscription preference to continue') }
    end

    context 'with a valid selectChapters' do
      subject(:form) { described_class.new(preference: Myott::StopPressPreferenceForm::SELECT_CHAPTERS) }

      it { is_expected.to be_valid }
    end

    context 'with a valid allChapters' do
      subject(:form) { described_class.new(preference: Myott::StopPressPreferenceForm::ALL_CHAPTERS) }

      it { is_expected.to be_valid }
    end
  end

  describe '#select_chapters?' do
    it { expect(described_class.new(preference: Myott::StopPressPreferenceForm::SELECT_CHAPTERS).select_chapters?).to be true }
    it { expect(described_class.new(preference: Myott::StopPressPreferenceForm::ALL_CHAPTERS).select_chapters?).to be false }
    it { expect(described_class.new(preference: nil).select_chapters?).to be false }
  end

  describe '#all_chapters?' do
    it { expect(described_class.new(preference: Myott::StopPressPreferenceForm::ALL_CHAPTERS).all_chapters?).to be true }
    it { expect(described_class.new(preference: Myott::StopPressPreferenceForm::SELECT_CHAPTERS).all_chapters?).to be false }
    it { expect(described_class.new(preference: nil).all_chapters?).to be false }
  end
end
