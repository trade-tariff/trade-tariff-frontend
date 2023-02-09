require 'spec_helper'

RSpec.describe RulesOfOrigin::Article do
  it { is_expected.to respond_to :article }
  it { is_expected.to respond_to :content }

  describe '#text' do
    subject { instance.text }

    context 'without ord reference' do
      let(:instance) { build :rules_of_origin_article }

      it { is_expected.to eql instance.content }
    end

    context 'with ord reference' do
      let(:instance) { build :rules_of_origin_article, :ord_reference }

      it { is_expected.not_to eql instance.content }
      it { is_expected.to match '### Some information' }
      it { is_expected.not_to match '{{' }
    end
  end

  describe 'ord_reference' do
    subject { instance.ord_reference }

    context 'without ord reference' do
      let(:instance) { build :rules_of_origin_article }

      it { is_expected.to be_nil }
    end

    context 'with ord reference' do
      let(:instance) { build :rules_of_origin_article, :ord_reference }

      it { is_expected.to eql 'articles 32 to 33' }
    end
  end

  describe 'ord_reference?' do
    subject { instance.ord_reference? }

    context 'without ord reference' do
      let(:instance) { build :rules_of_origin_article }

      it { is_expected.to be false }
    end

    context 'with ord reference' do
      let(:instance) { build :rules_of_origin_article, :ord_reference }

      it { is_expected.to be true }
    end
  end

  describe 'processing content with subsections' do
    subject(:instance) { build :rules_of_origin_article, content: }

    let :content do
      <<~EOCONTENT
        # Full title

        ## First section

        Section 1 content

        ### sub sub heading

        sub content

        ## Second section

        Section 2 content
      EOCONTENT
    end

    describe '#sections' do
      subject(:sections) { instance.sections }

      it { is_expected.to have_attributes length: 2 }

      context 'with first section' do
        subject { sections.first }

        it { is_expected.to include '## First section' }
        it { is_expected.to include '### sub sub heading' }
        it { is_expected.to include 'sub content' }
      end

      context 'with second section' do
        subject { sections.second }

        it { is_expected.to eql %(## Second section\n\nSection 2 content\n) }
      end

      context 'with no content' do
        let(:content) { nil }

        it 'returns an empty array' do
          expect(sections).to be_empty
        end
      end
    end

    describe '#subheadings' do
      subject { instance.subheadings }

      it { is_expected.to eql ['First section', 'Second section'] }
    end

    describe '#section' do
      context 'without section' do
        subject { instance.section(nil) }

        it { is_expected.to include '## First section' }
      end

      context 'with valid section' do
        subject { instance.section(2) }

        it { is_expected.to include '## Second section' }
      end

      context 'with invalid section' do
        subject { instance.section('foobar') }

        it { is_expected.to include '## First section' }
      end
    end
  end
end
