require 'spec_helper'

RSpec.describe RulesOfOrigin::Steps::ProofRequirements do
  include_context 'with rules of origin store', :originating
  include_context 'with wizard step', RulesOfOrigin::Wizard

  it_behaves_like 'an article accessor', :processes_text, 'origin_processes'

  describe '#skipped' do
    subject { instance.skipped? }

    it { is_expected.to be false }

    context "when 'wholly_obtained' set to 'yes'" do
      include_context 'with rules of origin store', :wholly_obtained

      it { is_expected.to be false }
    end

    context "when 'wholly_obtained' set to 'no'" do
      include_context 'with rules of origin store', :not_wholly_obtained

      it { is_expected.to be true }
    end
  end

  describe 'processes article content' do
    let :articles do
      attributes_for_list :rules_of_origin_article, 1,
                          article: 'origin_processes',
                          content:
    end

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

    describe '#processes_sections' do
      subject(:sections) { instance.processes_sections }

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
        subject(:sections) { instance.processes_sections }

        let(:articles) { [] }

        it 'returns an empty array' do
          expect(sections).to be_empty
        end
      end
    end

    describe '#processes_section_titles' do
      subject { instance.processes_section_titles }

      it { is_expected.to eql ['First section', 'Second section'] }
    end

    describe '#processes_section' do
      context 'without section' do
        subject { instance.processes_section(nil) }

        it { is_expected.to include '## First section' }
      end

      context 'with valid section' do
        subject { instance.processes_section(2) }

        it { is_expected.to include '## Second section' }
      end

      context 'with invalid section' do
        subject { instance.processes_section('foobar') }

        it { is_expected.to include '## First section' }
      end
    end
  end
end
