require 'spec_helper'

RSpec.describe SearchResultsHelper do
  describe '#render_confidence_meter' do
    context 'when confidence is strong' do
      let(:html) { helper.render_confidence_meter('strong') }

      it 'renders with correct class' do
        expect(html).to include('confidence-strong')
      end

      it 'renders with correct label' do
        expect(html).to include('Strong match')
      end
    end

    context 'when confidence is good' do
      let(:html) { helper.render_confidence_meter('good') }

      it 'renders with correct class' do
        expect(html).to include('confidence-good')
      end

      it 'renders with correct label' do
        expect(html).to include('Good match')
      end
    end

    context 'when confidence is possible' do
      let(:html) { helper.render_confidence_meter('possible') }

      it 'renders with correct class' do
        expect(html).to include('confidence-possible')
      end

      it 'renders with correct label' do
        expect(html).to include('Possible match')
      end
    end

    context 'when confidence is unlikely' do
      let(:html) { helper.render_confidence_meter('unlikely') }

      it 'renders with correct class' do
        expect(html).to include('confidence-unlikely')
      end

      it 'renders with correct label' do
        expect(html).to include('Unlikely match')
      end
    end

    context 'when confidence is nil' do
      it 'renders unknown indicator' do
        expect(helper.render_confidence_meter(nil)).to include('confidence-unknown')
      end
    end

    context 'when confidence is unrecognized' do
      it 'renders unknown indicator' do
        expect(helper.render_confidence_meter('unrecognized')).to include('confidence-unknown')
      end
    end
  end

  describe '#normalize_options_to_json' do
    context 'when options is nil' do
      it 'returns empty array JSON' do
        expect(helper.normalize_options_to_json(nil)).to eq('[]')
      end
    end

    context 'when options is blank' do
      it 'returns empty array JSON' do
        expect(helper.normalize_options_to_json('')).to eq('[]')
      end
    end

    context 'when options is an array' do
      it 'returns JSON encoded array' do
        expect(helper.normalize_options_to_json(%w[A B C])).to eq('["A","B","C"]')
      end
    end

    context 'when options is a JSON string' do
      it 'parses and re-encodes cleanly' do
        expect(helper.normalize_options_to_json('["A","B"]')).to eq('["A","B"]')
      end
    end

    context 'when options is double-encoded JSON' do
      it 'unwraps and returns clean array' do
        double_encoded = '["A","B"]'.to_json
        expect(helper.normalize_options_to_json(double_encoded)).to eq('["A","B"]')
      end
    end

    context 'when options is invalid JSON' do
      it 'returns empty array JSON' do
        expect(helper.normalize_options_to_json('not json at all')).to eq('[]')
      end
    end
  end
end
