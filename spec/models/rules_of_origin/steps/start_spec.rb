require 'spec_helper'

RSpec.describe RulesOfOrigin::Steps::Start do
  include_context 'with wizard store'
  include_context 'with wizard step', RulesOfOrigin::Wizard

  it { is_expected.to respond_to :service }
  it { is_expected.to respond_to :country_code }
  it { is_expected.to respond_to :commodity_code }

  describe '#services' do
    subject { instance.service_choices }

    it { is_expected.to eql %w[uk xi] }
  end

  describe 'validation' do
    include_context 'with rules of origin store'

    describe 'service' do
      it { is_expected.to validate_inclusion_of(:service).in_array %w[uk xi] }
    end

    describe 'country_code' do
      it { is_expected.to validate_presence_of :country_code }
      it { is_expected.to allow_value('JP').for :country_code }
    end

    describe 'commodity_code' do
      it { is_expected.to validate_presence_of :commodity_code }
      it { is_expected.to allow_value('6004100091').for :commodity_code }
      it { is_expected.to allow_value('6004100099').for :commodity_code }
    end
  end

  describe '#save!' do
    include_context 'with rules of origin store', :importing

    context 'when valid' do
      it 'resets the wizard store' do
        instance.save!

        expect(wizardstore.keys).to match_array %w[service country_code commodity_code]
      end

      it 'returns true' do
        expect(instance.save!).to be true
      end

      it 'assigns the service automatically' do
        instance.save!

        expect(wizardstore['service']).to eql 'uk'
      end
    end

    context 'when invalid' do
      before { instance.commodity_code = nil }

      it 'raises an exception' do
        expect { instance.save! }.to raise_exception described_class::RecordInvalid
      end
    end
  end
end
