RSpec.describe RulesOfOriginHelper, :user_session do
  let(:user_session) { build(:user_session) }

  describe '#scheme_for' do
    subject { helper.scheme_for(option, schemes) }

    let(:schemes) do
      [
        build(:rules_of_origin_scheme, scheme_code: 'foo'),
        build(:rules_of_origin_scheme, scheme_code: 'bar'),
      ]
    end

    context 'when there is a matching scheme' do
      let(:option) { build(:duty_option_result, scheme_code: 'foo') }

      it { is_expected.to eq(schemes.first) }
    end

    context 'when there is no matching scheme' do
      let(:option) { build(:duty_option_result, scheme_code: 'qux') }

      it { is_expected.to be_nil }
    end
  end

  describe '#rules_of_origin_tagged_descriptions' do
    subject { helper.rules_of_origin_tagged_descriptions(content) }

    context 'without tagged descriptions' do
      let(:content) { 'Some sample content' }

      it { is_expected.to eql content }
    end

    context 'with matching tagged descriptions' do
      let(:content) { "With two tags in\n\n{{CC}}{{CTSH}}" }

      it { is_expected.to start_with 'With two tags in' }
      it { is_expected.to match 'change of chapter' }
      it { is_expected.to match 'change in tariff subheading' }
    end

    context 'with unmatched tagged descriptions' do
      let(:content) { "With two tags in\n\n{{UNKNOWN}}{{CTSH}}" }

      it { is_expected.to start_with 'With two tags in' }
      it { is_expected.not_to match '{{CC}}' }
      it { is_expected.not_to match 'change of chapter' }
      it { is_expected.to match 'change in tariff subheading' }
    end
  end

  describe '#replace_non_breaking_space' do
    subject { helper.replace_non_breaking_space content }

    let(:content) { 'With space and&nbsp;non-breaking&nbsp;space' }

    it { is_expected.to eql 'With space and non-breaking space' }
  end

  describe '#restrict_wrapping' do
    subject { helper.restrict_wrapping content }

    let(:span) { '<span class="rules-of-origin__non-breaking-heading">' }

    context 'with single replacement' do
      let(:content) { 'ex Chapter 123 456' }

      it { is_expected.to eql "ex #{span}Chapter 123</span> 456" }
    end

    context 'with multiple replacements' do
      let(:content) { 'ex 123, ex 456 and ex 789' }

      let :expected do
        "#{span}ex 123</span>, #{span}ex 456</span> and #{span}ex 789</span>"
      end

      it { is_expected.to eql expected }
    end
  end
end
