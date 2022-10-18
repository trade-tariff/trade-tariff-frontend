require 'spec_helper'

RSpec.describe Beta::Search::InterceptMessage do
  describe '#html_message' do
    subject(:intercept_message) do
      formatted_message = '[chapter 85](/chapters/85)'

      build(:intercept_message, formatted_message:).html_message
    end

    it { is_expected.to be_html_safe }
    it { is_expected.to include('<a href="/chapters/85">chapter 85</a>') }
  end
end
