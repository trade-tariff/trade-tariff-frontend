require 'spec_helper'

RSpec.describe SearchResultsHelper do
  describe '#render_confidence_meter' do
    context 'when confidence is strong' do
      let(:html) { helper.render_confidence_meter('strong') }

      it 'renders with correct class' do
        expect(html).to include('confidence-strong')
      end

      it 'renders with correct label' do
        expect(html).to include('Strong result')
      end
    end

    context 'when confidence is good' do
      let(:html) { helper.render_confidence_meter('good') }

      it 'renders with correct class' do
        expect(html).to include('confidence-good')
      end

      it 'renders with correct label' do
        expect(html).to include('Good result')
      end
    end

    context 'when confidence is possible' do
      let(:html) { helper.render_confidence_meter('possible') }

      it 'renders with correct class' do
        expect(html).to include('confidence-possible')
      end

      it 'renders with correct label' do
        expect(html).to include('Possible result')
      end
    end

    it 'renders three coloured meter segments', :aggregate_failures do
      fragment = Capybara.string(helper.render_confidence_meter('strong'))

      expect(fragment).to have_css('svg.confidence-gauge path[data-confidence-segment]', count: 3)
      expect(fragment).to have_css('svg.confidence-gauge path[fill="#D4351C"]', count: 1)
      expect(fragment).to have_css('svg.confidence-gauge path[fill="#FFDD00"]', count: 1)
      expect(fragment).to have_css('svg.confidence-gauge path[fill="#00703C"]', count: 1)
      expect(fragment).not_to have_css('svg.confidence-gauge path[fill="#FF9F00"]')
      expect(fragment).not_to have_css('svg.confidence-gauge path[fill="#EADD00"]')
    end

    it 'renders each needle from the design source SVGs', :aggregate_failures do
      expected_needle_paths = {
        'possible' => 'M63.6185 59.3216C66.4791 57.6154 70.1528 57.465 73.2422 59.2486C77.786 61.872 79.3428 67.6821 76.7194 72.2259C74.0961 76.7696 68.286 78.3265 63.7422 75.7031C60.462 73.8092 58.7389 70.2545 59.021 66.7144L16.2295 36.9975L63.6185 59.3216Z',
        'good' => 'M73.1211 59.2021C76.0289 60.8264 77.9961 63.9327 77.9961 67.5C77.9961 72.7467 73.7428 77 68.4961 77C63.2494 77 58.9961 72.7467 58.9961 67.5C58.9961 63.7123 61.213 60.4427 64.4199 58.917L68.7588 7L73.1211 59.2021Z',
        'strong' => 'M77.9733 67.3337C78.0206 70.664 76.314 73.9208 73.2246 75.7045C68.6808 78.3278 62.8707 76.771 60.2474 72.2272C57.624 67.6835 59.1808 61.8734 63.7246 59.25C67.005 57.3561 70.9457 57.6405 73.8705 59.6552L121 37.4547L77.9733 67.3337Z',
      }

      expected_needle_paths.each do |confidence, expected_path|
        needle_path = Capybara.string(helper.render_confidence_meter(confidence)).find('svg.confidence-gauge path[fill="#0B0C0C"]', match: :first)[:d]

        expect(needle_path).to eq(expected_path)
      end
    end

    it 'does not render an unlikely meter option', :aggregate_failures do
      html = helper.render_confidence_meter('unlikely')

      expect(html).to include('confidence-unknown')
      expect(html).not_to include('Unlikely result')
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
