RSpec.describe 'search/_interactive_dont_know', type: :view do
  subject { render partial: 'search/interactive_dont_know' }

  it { is_expected.to have_css('h1', text: "We can't suggest a tariff code yet") }
  it { is_expected.to have_text('To find the relevant commodity code, we need more information about the product.') }
  it { is_expected.to have_css('h2', text: 'Where can I find this information?') }
  it { is_expected.to have_text('invoice or other billing documents') }
  it { is_expected.to have_text('online listings') }
  it { is_expected.to have_text('product information documents included in the packaging') }
  it { is_expected.to have_css('h2', text: 'Next steps') }
  it { is_expected.to have_text('Go back and add more details so we can find the relevant commodity code with the highest accuracy.') }
  it { is_expected.to have_css('button', text: 'Go back and add more details') }
  it { is_expected.to have_link('Start search again') }
  it { is_expected.to have_link('Cancel') }

  describe 'alternative search cards' do
    it { is_expected.to have_css('h2', text: 'Other ways to search for a commodity') }
    it { is_expected.to have_link('Keyword or commodity code') }
    it { is_expected.to have_link('Goods classifications') }
    it { is_expected.to have_link('A-Z product index') }
  end
end
