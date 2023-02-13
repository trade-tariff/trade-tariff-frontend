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

    describe '#processes_contents_list' do
      subject { instance.processes_contents_list }

      it { is_expected.to include ['First section', 1] }
      it { is_expected.to include ['Second section', 2] }
    end

    describe '#processes_section' do
      subject { instance.processes_section(2) }

      it { is_expected.to include '## Second section' }
    end
  end
end
