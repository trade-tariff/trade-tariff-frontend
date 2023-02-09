require 'spec_helper'

RSpec.describe RulesOfOrigin::Steps::ProofRequirements do
  include_context 'with rules of origin store', :originating
  include_context 'with wizard step', RulesOfOrigin::Wizard

  it_behaves_like 'an article accessor', :processes_text, 'origin_processes'

  describe '#skipped?' do
    subject { instance.skipped? }

    it { is_expected.to be true }
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
    end

    describe '#processes_section_titles' do
      subject { instance.processes_section_titles }

      it { is_expected.to eql ['First section', 'Second section'] }
    end

    describe '#processes_section' do
      subject { instance.processes_section(2) }

      it { is_expected.to include '## Second section' }
    end
  end
end
