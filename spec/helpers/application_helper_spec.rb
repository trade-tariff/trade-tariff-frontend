require 'spec_helper'

describe ApplicationHelper, type: :helper do
  describe '#govspeak' do
    context 'string without HTML code' do
      let(:string) { '**hello**' }

      it 'renders string in Markdown as HTML' do
        expect(
          helper.govspeak(string).strip,
        ).to eq '<p><strong>hello</strong></p>'
      end
    end

    context 'string contains Javascript code' do
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
end
