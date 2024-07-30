RSpec.describe GreenLanes::CheckYourAnswersController, type: :request, vcr: {
  cassette_name: 'green_lanes/check_your_answers',
  record: :new_episodes,
} do
  describe 'GET #new' do
    before { make_request }

    let(:make_request) do
      get new_green_lanes_check_your_answers_path(
        commodity_code: '4114109000',
        country_of_origin: 'UA',
        moving_date: '2024-05-29',
        ans: {
          '1' => {
            '34' => %w[Y997],
            '82' => %w[Y984],
          },
          '2' => {
            '5' => %w[none],
          },
        },
        category: 2,
        c1ex: true,
        c2ex: false,
      )
    end

    it 'responds with status code :ok' do
      expect(response).to have_http_status(:ok), "Response body: #{response.body}"
    end

    it 'assigns the correct instance variables', :aggregate_failures do
      expect(assigns(:commodity_code)).to eq('4114109000')
      expect(assigns(:country_of_origin)).to eq('UA')
      expect(assigns(:moving_date)).to eq('2024-05-29')
      expect(assigns(:category_one_assessments)).to all(be_a(GreenLanes::CategoryAssessment))
      expect(assigns(:category_two_assessments)).to all(be_a(GreenLanes::CategoryAssessment))
      expect(assigns(:answers)).not_to be_nil
      expect(assigns(:c1ex)).to eq('true')
      expect(assigns(:c2ex)).to eq('false')
    end

    it 'renders the new template', :aggregate_failures do
      expect(response).to render_template('green_lanes/check_your_answers/new')
      expect(response).to render_template('green_lanes/shared/_summary_card')
      expect(response).to render_template('green_lanes/check_your_answers/_category_exemptions')
    end
  end
end
