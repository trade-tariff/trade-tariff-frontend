require 'spec_helper'

RSpec.describe 'webchat_message/_footer', type: :view do
  shared_examples_for 'a webchat link' do |partial_view|
    subject(:rendered_page) do
      render partial_view

      rendered
    end

    context 'when ENV WEBCHAT_URL is set' do
      before do
        allow(TradeTariffFrontend).to receive(:webchat_url).and_return('http://webchat_url_test')
      end

      it 'displays the webchat link ' do
        expect(subject).to have_css '#webchat-link'
      end
    end

    context 'when ENV WEBCHAT_URL is not set' do
      before do
        allow(TradeTariffFrontend).to receive(:webchat_url).and_return(nil)
      end

      it { is_expected.not_to have_css '#webchat-link' }
    end
  end

  it_behaves_like 'a webchat link', 'shared/webchat_message/footer'
  it_behaves_like 'a webchat link', 'shared/webchat_message/help'
  it_behaves_like 'a webchat link', 'shared/webchat_message/not_found'
end
