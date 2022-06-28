require 'spec_helper'

RSpec.describe RulesOfOrigin::Steps::WhollyObtainedDefinition do
  include_context 'with rules of origin store', :originating
  include_context 'with wizard step', RulesOfOrigin::Wizard

  describe '#scheme_title' do
    subject { instance.scheme_title }

    it { is_expected.to eql schemes.first.title }

    context 'with multiple schemes' do
      include_context 'with rules of origin store', :importing, scheme_count: 2,
                                                                chosen_scheme: 2

      it { is_expected.to eql schemes.second.title }
    end
  end

  describe '#wholly_obtained_text' do
    subject { instance.wholly_obtained_text }

    context 'with matching article' do
      let(:articles) do
        attributes_for_list :rules_of_origin_article, 1, article: 'wholly-obtained'
      end

      it { is_expected.to eql articles.first[:content] }
    end

    context 'without matching article' do
      it { is_expected.to be_nil }
    end
  end

  describe '#wholly_obtained_vessels_text' do
    subject { instance.wholly_obtained_vessels_text }

    context 'with matching article' do
      let(:articles) do
        attributes_for_list :rules_of_origin_article, 1, article: 'wholly-obtained-vessels'
      end

      it { is_expected.to eql articles.first[:content] }
    end

    context 'without matching article' do
      let(:articles) { [] }

      it { is_expected.to be_nil }
    end
  end
end
