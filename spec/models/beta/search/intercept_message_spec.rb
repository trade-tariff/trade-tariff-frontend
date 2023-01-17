require 'spec_helper'

RSpec.describe Beta::Search::InterceptMessage do
  subject(:intercept_message) { build :intercept_message, formatted_message: }

  let(:formatted_message) { '[chapter 85](/chapters/85)' }

  describe '#html_message' do
    subject { intercept_message.html_message }

    it { is_expected.to be_html_safe }
    it { is_expected.to include('<a href="/chapters/85">chapter 85</a>') }

    context 'with unmarkuped hyperlink' do
      let(:formatted_message) { 'this is a *link* to https://www.gov.uk/' }

      it { is_expected.to be_html_safe }
      it { is_expected.to include '<em>link</em>' }
      it { is_expected.to include '<a href="https://www.gov.uk/">https://www.gov.uk/</a>' }
    end
  end
end
