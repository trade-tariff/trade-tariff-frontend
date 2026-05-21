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
      expect(fragment).to have_css('svg.confidence-gauge path[fill="#FF9F00"]', count: 1)
      expect(fragment).to have_css('svg.confidence-gauge path[fill="#EADD00"]', count: 1)
      expect(fragment).to have_css('svg.confidence-gauge path[fill="#00703C"]', count: 1)
      expect(fragment).not_to have_css('svg.confidence-gauge path[fill="#D4351C"]')
    end

    it 'positions each confidence needle on the three-part meter', :aggregate_failures do
      expected_tip_ranges = {
        'possible' => { x: 0..30, y: 30..50 },
        'good' => { x: 55..82, y: 0..20 },
        'strong' => { x: 105..135, y: 35..55 },
      }

      expected_tip_ranges.each do |confidence, ranges|
        needle_path = Capybara.string(helper.render_confidence_meter(confidence)).find('svg.confidence-gauge path[fill="black"]', match: :first)[:d]
        x, y = needle_path.match(/\AM(?<x>\d+(?:\.\d+)?) (?<y>\d+(?:\.\d+)?)/).captures.map(&:to_f)

        expect(ranges[:x]).to cover(x), "#{confidence} needle x-position #{x} is outside #{ranges[:x]}"
        expect(ranges[:y]).to cover(y), "#{confidence} needle y-position #{y} is outside #{ranges[:y]}"
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
