RSpec.describe ApplicationHelper do
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
end
