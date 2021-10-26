require 'spec_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#govspeak' do
    context 'with string without HTML code' do
      let(:string) { '**hello**' }

      it 'renders string in Markdown as HTML' do
        expect(
          helper.govspeak(string).strip,
        ).to eq '<p><strong>hello</strong></p>'
      end
    end

    context 'when string contains Javascript code' do
      let(:string) { "<script type='text/javascript'>alert('hello');</script>" }

      it '<script> tags with a content are filtered' do
        expect(
          helper.govspeak(string).strip,
        ).to eq ''
      end
    end

    context 'when HashWithIndifferentAccess is passed as argument' do
      let(:hash) do
        { 'content' => '* 1\\. This chapter does not cover:' }
      end

      it 'fetches :content from the hash' do
        expect(
          helper.govspeak(hash),
        ).to eq <<~FOO
          <ul>
            <li>1. This chapter does not cover:</li>
          </ul>
        FOO
      end
    end

    context 'when HashWithIndifferentAccess is passed as argument with no applicable content' do
      let(:na_hash) do
        { 'foo' => 'bar' }
      end

      it 'returns an empty string' do
        expect(
          helper.govspeak(na_hash),
        ).to eq ''
      end
    end
  end

  describe '.generate_breadcrumbs' do
    it 'returns current page list item' do
      expect(helper.generate_breadcrumbs('Current Page', [])).to match(/Current Page/)
    end

    it 'returns previous pages breadcrumbs' do
      expect(helper.generate_breadcrumbs('Current Page', [['Previous Page', '/']])).to match(/Previous Page/)
    end
  end

  describe '.tools_active_class' do
    let(:action) { 'something' }

    before do
      allow(controller).to receive(:params).and_return(action: action)
    end

    context 'when action is tools' do
      let(:action) { 'tools' }

      it 'returns active' do
        expect(helper.tools_active_class).to eq('active')
      end
    end

    context 'when action is not tools' do
      it 'returns nil' do
        expect(helper.tools_active_class).to be_nil
      end
    end
  end

  describe '.help_active_class' do
    let(:action) { 'something' }

    before do
      allow(controller).to receive(:params).and_return(action: action)
    end

    context 'when action is tools' do
      let(:action) { 'help' }

      it 'returns active' do
        expect(helper.help_active_class).to eq('active')
      end
    end

    context 'when action is not tools' do
      it 'returns nil' do
        expect(helper.help_active_class).to be_nil
      end
    end
  end

  describe '#page_header' do
    context 'without block' do
      subject { helper.page_header 'Test header' }

      it { is_expected.to have_css 'header span.govuk-caption-m', text: I18n.t('title.service_name.uk') }
      it { is_expected.to have_css 'header h1.govuk-heading-l', text: 'Test header' }
      it { is_expected.to have_css 'header *', count: 2 }
    end

    context 'with block' do
      subject { helper.page_header('Second header') { tag.em 'additional content' } }

      it { is_expected.to have_css 'header span.govuk-caption-m', text: I18n.t('title.service_name.uk') }
      it { is_expected.to have_css 'header h1.govuk-heading-l', text: 'Second header' }
      it { is_expected.to have_css 'header *', count: 3 }
      it { is_expected.to have_css 'header em', text: 'additional content' }
    end

    context 'with XI service' do
      subject { helper.page_header 'Test header' }

      include_context 'with XI service'

      it { is_expected.to have_css 'header span.govuk-caption-m', text: I18n.t('title.service_name.xi') }
    end
  end
end
