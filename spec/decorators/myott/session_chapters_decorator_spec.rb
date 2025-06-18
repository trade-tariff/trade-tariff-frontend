require 'spec_helper'

RSpec.describe Myott::SessionChaptersDecorator do
  subject(:decorator) { described_class.new(session) }

  let(:session) { {} }

  let(:section1) { instance_double(Section, title: 'Section 1', resource_id: 1) }
  let(:section2) { instance_double(Section, title: 'Section 1', resource_id: 1) }
  let(:chapter1) { instance_double(Chapter, to_param: '01', short_code: '01', to_s: 'Live animals') }
  let(:chapter2) { instance_double(Chapter, to_param: '02', short_code: '02', to_s: 'Meat') }
  let(:chapter3) { instance_double(Chapter, to_param: '03', short_code: '03', to_s: 'Fish and crustaceans, molluscs and other aquatic invertebrates') }

  before do
    allow(Rails.cache).to receive(:fetch).with('all_sections_chapters', expires_in: 1.day)
      .and_return({ section1 => [chapter1, chapter2], section2 => [chapter3] })
  end

  describe '#all_chapters' do
    it 'returns flattened list of all chapters from all sections' do
      expect(decorator.all_chapters).to eq([chapter1, chapter2, chapter3])
    end
  end

  describe '#all_sections_chapters' do
    it 'returns hash with sections as keys and arrays of chapters as values' do
      result = decorator.all_sections_chapters
      expect(result).to eq({
        section1 => [chapter1, chapter2],
        section2 => [chapter3],
      })
    end
  end

  describe '#selected_chapters_heading' do
    context 'when no chapters are selected' do
      before do
        session[:chapter_ids] = []
      end

      it 'returns heading for all chapters' do
        expect(decorator.selected_chapters_heading).to eq('You have selected all chapters')
      end
    end

    context 'when all chapters are selected' do
      before do
        session[:chapter_ids] = %w[01 02 03]
      end

      it 'returns heading for all chapters' do
        expect(decorator.selected_chapters_heading).to eq('You have selected all chapters')
      end
    end

    context 'when one chapter is selected' do
      before do
        session[:chapter_ids] = %w[01]
      end

      it 'returns singular heading' do
        expect(decorator.selected_chapters_heading).to eq('You have selected 1 chapter')
      end
    end

    context 'when multiple chapters are selected' do
      before do
        session[:chapter_ids] = %w[01 02]
      end

      it 'returns plural heading' do
        expect(decorator.selected_chapters_heading).to eq('You have selected 2 chapters')
      end
    end
  end

  describe '#selected_chapters' do
    before do
      session[:chapter_ids] = %w[01 03]
    end

    it 'returns flattened values from selected_sections_chapters' do
      expect(decorator.selected_chapters).to eq([chapter1, chapter3])
    end
  end

  describe '#selected_sections_chapters' do
    context 'when some chapters are selected' do
      before do
        session[:chapter_ids] = %w[01 02]
      end

      it 'returns sections with selected chapters' do
        result = decorator.selected_sections_chapters
        expect(result).to eq({
          section1 => [chapter1, chapter2],
        })
      end
    end

    context 'when no chapters are selected' do
      before do
        session[:chapter_ids] = []
      end

      it 'returns empty hash' do
        expect(decorator.selected_sections_chapters).to eq({})
      end
    end

    context 'when chapter_ids is nil' do
      before do
        session[:chapter_ids] = nil
      end

      it 'returns empty hash' do
        expect(decorator.selected_sections_chapters).to eq({})
      end
    end
  end

  describe '#delete' do
    before do
      session[:chapter_ids] = %w[01 02 03]
      session[:all_tariff_updates] = true
    end

    it 'removes chapter_ids from session' do
      decorator.delete
      expect(session[:chapter_ids]).to be_nil
    end

    it 'removes all_tariff_updates from session' do
      decorator.delete
      expect(session[:all_tariff_updates]).to be_nil
    end
  end
end
