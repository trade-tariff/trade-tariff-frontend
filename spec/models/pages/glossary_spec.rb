require 'spec_helper'

RSpec.describe Pages::Glossary do
  subject { described_class.new 'max_nom' }

  it { is_expected.to have_attributes key: 'max_nom' }
  it { is_expected.to have_attributes term: 'MaxNOM' }
  it { is_expected.to have_attributes title: /maximum value/i }
  it { is_expected.to have_attributes term_and_title: /MaxNOM \(.*maximum value.*\)/i }

  describe '.find' do
    context 'with safe page term' do
      subject { described_class.find 'max_nom' }

      it { is_expected.to be_instance_of described_class }
      it { is_expected.to have_attributes key: 'max_nom' }
      it { is_expected.to have_attributes term: 'MaxNOM' }
      it { is_expected.to have_attributes title: /maximum value/i }
    end

    context 'with unsafe page term' do
      let(:unsafe) { described_class.find '../../../etc/passwd' }

      it { expect { unsafe }.to raise_exception described_class::UnknownPage }
    end

    context 'with unknown page' do
      subject(:unknown) { described_class.find('something_random') }

      it { expect { unknown }.to raise_exception described_class::UnknownPage }
    end
  end

  describe '.all' do
    subject { described_class.all }

    it { is_expected.to have_attributes length: described_class::PAGES.length }
    it { is_expected.to all be_instance_of described_class }
  end
end
