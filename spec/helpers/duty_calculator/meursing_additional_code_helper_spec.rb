RSpec.describe DutyCalculator::MeursingAdditionalCodeHelper do
  describe '#meursing_lookup_hint_text' do
    subject(:meursing_lookup_hint_text) { helper.meursing_lookup_hint_text }

    include_context 'with XI service'

    it { is_expected.to be_html_safe }

    it 'returns the properly sanitized hint' do
      expected_hint = 'If you know the additional code for your commodity, enter it in the box below. If you do not know the code, then use the <a class="govuk-link" target="_blank" rel="noopener norefferer" href="/xi/meursing_lookup/steps/start">Meursing code finder (opens in new tab)</a> to find the additional code.'

      expect(meursing_lookup_hint_text).to include(expected_hint)
    end
  end
end
