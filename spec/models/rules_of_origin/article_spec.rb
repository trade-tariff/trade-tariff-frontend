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
end
