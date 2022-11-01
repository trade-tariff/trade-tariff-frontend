require 'spec_helper'

RSpec.describe Pages::Glossary do
  describe '#new' do
    context 'with safe page term' do
      subject { described_class.new 'some_term' }

      it { is_expected.to be_instance_of described_class }
      it { is_expected.to have_attributes term: 'some_term' }
    end

    context 'with unsafe page term' do
      let(:unsafe) { described_class.new '../../../etc/passwd' }

      it { expect { unsafe }.to raise_exception described_class::UnsafePageTerm }
    end

    context 'with unknown page' do
      subject(:unknown) { described_class.new('something_random').page }

      it { expect { unknown }.to raise_exception described_class::UnknownPage }
    end
  end

  describe '#page' do
    context 'with known page' do
      subject { described_class.new('vnm').page }

      it { is_expected.to eql 'pages/glossary/vnm' }
    end
  end
end
