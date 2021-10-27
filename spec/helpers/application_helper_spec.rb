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

  describe '#search_active_class' do
    subject { helper.search_active_class }

    before do
      allow(helper).to receive(:controller_name).and_return controller_name
      allow(helper).to receive(:action_name).and_return action
    end

    context 'with sections page' do
      let(:controller_name) { 'sections' }
      let(:action) { 'index' }

      it { is_expected.to eq 'active' }
    end

    context 'with search results page' do
      let(:controller_name) { 'search' }
      let(:action) { 'search' }

      it { is_expected.to eq 'active' }
    end

    context 'with another page' do
      let(:controller_name) { 'browse' }
      let(:action) { 'index' }

      it { is_expected.to be_nil }
    end
  end

  describe '#a_z_active_class' do
    subject { helper.a_z_active_class }

    context 'when controller is search_references' do
      before { allow(helper).to receive(:controller_name).and_return('search_references') }

      it { is_expected.to eql 'active' }
    end

    context 'when controller is not tools' do
      before { allow(helper).to receive(:controller_name).and_return('something') }

      it { is_expected.to be_nil }
    end
  end

  describe '#tools_active_class' do
    subject { helper.tools_active_class }

    context 'when action is tools' do
      before { allow(helper).to receive(:action_name).and_return('tools') }

      it { is_expected.to eql 'active' }
    end

    context 'when action is not tools' do
      before { allow(helper).to receive(:action_name).and_return('something') }

      it { is_expected.to be_nil }
    end
  end

  describe '#help_active_class' do
    subject { helper.help_active_class }

    context 'when action is tools' do
      before { allow(helper).to receive(:action_name).and_return('help') }

      it { is_expected.to eql 'active' }
    end

    context 'when action is not tools' do
      before { allow(helper).to receive(:action_name).and_return('something') }

      it { is_expected.to be_nil }
    end
  end

  describe '#browse_active_class' do
    subject { helper.browse_active_class }

    context 'with browse controller' do
      before { allow(helper).to receive(:controller_name).and_return 'browse_sections' }

      it { is_expected.to eql 'active' }
    end

    context 'with other controller' do
      before { allow(helper).to receive(:controller_name).and_return 'search' }

      it { is_expected.to be_nil }
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
