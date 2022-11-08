require 'spec_helper'

RSpec.describe Pages::Glossary do
  describe '.new' do
    subject { described_class.new 'test' }

    it { is_expected.to have_attributes term: 'test' }
  end

  describe '#find' do
    before { allow(described_class).to receive(:pages).and_return %w[some_term] }

    context 'with safe page term' do
      subject { described_class.find 'some_term' }

      it { is_expected.to be_instance_of described_class }
      it { is_expected.to have_attributes term: 'some_term' }
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

  describe '#page' do
    context 'with known page' do
      subject { described_class.new('something').page }

      it { is_expected.to eql 'pages/glossary/something' }
    end
  end
end
