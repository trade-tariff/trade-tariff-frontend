RSpec.describe GreenLanes::FaqHelper, type: :helper do
  describe '#faq_categories' do
    before do
      allow(helper).to receive(:t).with('green_lanes_faq.faq_categories').and_return(
        {
          'category_1' => {
            heading: 'Categorisation ‘basics’',
            questions: {
              'question_1' => {
                question: 'What is Categorisation and why is it important?',
                answer: '<p>Sample answer with <strong>HTML</strong>.</p>',
              },
            },
          },
        },
      )
      allow(helper).to receive(:interpolate).and_wrap_original do |_original_method, text|
        text.gsub('%{green_lanes_start_path}', '/start-path')
      end
    end

    it 'returns an array' do
      result = helper.faq_categories
      expect(result).to be_an(Array)
    end

    it 'returns a category with the correct size' do
      result = helper.faq_categories
      expect(result.size).to eq(1)
    end

    it 'returns a category with the correct div_id' do
      result = helper.faq_categories
      category = result.first
      expect(category[:div_id]).to eq('category-heading-1')
    end

    it 'returns a category with the correct heading' do
      result = helper.faq_categories
      category = result.first
      expect(category[:heading]).to eq('Categorisation ‘basics’')
    end

    it 'returns a category with questions' do
      result = helper.faq_categories
      category = result.first
      expect(category[:questions]).to be_an(Array)
    end

    it 'returns a category with the correct number of questions' do
      result = helper.faq_categories
      category = result.first
      expect(category[:questions].size).to eq(1)
    end

    it 'returns a question with the correct div_id' do
      result = helper.faq_categories
      category = result.first
      question = category[:questions].first
      expect(question[:div_id]).to eq('content-heading-1')
    end

    it 'returns a question with the correct question text' do
      result = helper.faq_categories
      category = result.first
      question = category[:questions].first
      expect(question[:question]).to eq('What is Categorisation and why is it important?')
    end

    it 'returns a question with the correct answer' do
      result = helper.faq_categories
      category = result.first
      question = category[:questions].first
      expect(question[:answer]).to eq('<p>Sample answer with <strong>HTML</strong>.</p>')
    end

    it 'returns a question with the correct feedback_id' do
      result = helper.faq_categories
      category = result.first
      question = category[:questions].first
      expect(question[:feedback_id]).to eq('category_1 | question_1')
    end
  end

  describe '#related_links' do
    before do
      allow(helper).to receive(:t).with('green_lanes_faq.related_links').and_return(
        {
          'link_1' => '/path-to-link-1',
          'link_2' => '/path-to-link-2',
        },
      )
      allow(helper).to receive(:interpolate).and_wrap_original do |_original_method, link|
        link # Just return the link as it is (no interpolation needed)
      end
    end

    it 'returns an array' do
      result = helper.related_links
      expect(result).to be_an(Array)
    end

    it 'returns the correct number of links' do
      result = helper.related_links
      expect(result.size).to eq(2)
    end

    it 'includes the first link' do
      result = helper.related_links
      expect(result).to include({ link: '/path-to-link-1' })
    end

    it 'includes the second link' do
      result = helper.related_links
      expect(result).to include({ link: '/path-to-link-2' })
    end
  end

  describe '#interpolate' do
    context 'when the interpolation key is present' do
      it 'interpolates the text with the provided path' do
        allow(helper).to receive(:green_lanes_start_path).and_return('/start-path')
        result = helper.send(:interpolate, 'Visit %{green_lanes_start_path} for more information.')
        expect(result).to eq('Visit /start-path for more information.')
      end
    end
  end
end
