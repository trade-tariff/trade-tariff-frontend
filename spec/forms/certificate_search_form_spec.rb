RSpec.describe CertificateSearchForm, type: :model, vcr: { cassette_name: 'search#certificate_search', record: :new_episodes } do
  describe '.certificate_types' do
    subject(:certificate_types) { described_class.certificate_types }

    it { is_expected.to eq(%w[9 A C D E H I K L N P R T U X Y Z]) }
  end

  describe 'validations' do
    subject(:form) { described_class.new(params) }

    before { form.valid? }

    context 'when the code is valid' do
      let(:params) { { code: '9180' } }

      it { is_expected.to be_valid }
      it { expect(form.errors).to be_empty }
    end

    context 'when the description is valid' do
      let(:params) { { description: 'plastic' } }

      it { is_expected.to be_valid }
      it { expect(form.errors).to be_empty }
    end

    context 'when neither code nor description are present' do
      let(:params) { { code: '', description: '' } }

      it { is_expected.not_to be_valid }
      it { expect(form.errors[:description]).to eq(['You need to supply at least a description']) }
      it { expect(form.errors[:code]).to eq(['You need to supply at least a 4-digit certificate code']) }
    end

    context 'when the code is too short' do
      let(:params) { { code: '923' } }

      it { is_expected.not_to be_valid }
      it { expect(form.errors[:code]).to be_present }
    end

    context 'when the code include initial and ending spaces' do
      let(:params) { { code: '  a180 ' } }

      it { is_expected.to be_valid }
      it { is_expected.to have_attributes(code: 'A180') }
    end

    context 'when the code has invalid characters' do
      let(:params) { { code: 'a18-' } }

      it { is_expected.not_to be_valid }
      it { expect(form.errors[:code]).to be_present }
    end

    context 'when the code is a type that does not exist' do
      let(:params) { { code: '1234' } }

      it { is_expected.not_to be_valid }
      it { expect(form.errors[:code]).to be_present }
    end
  end

  describe '#type' do
    subject(:type) { described_class.new(params).type }

    context 'when the code is valid' do
      let(:params) { { code: '9180' } }

      it { is_expected.to eq('9') }
    end

    context 'when the code is not set' do
      let(:params) { {} }

      it { is_expected.to be_nil }
    end
  end

  describe '#to_params' do
    subject(:params) { described_class.new(code: '9180', description: 'plastic').to_params }

    it { is_expected.to eq(code: '180', type: '9', description: 'plastic') }
  end
end
