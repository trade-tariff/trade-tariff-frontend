RSpec.describe GreenLanes::CheckYourAnswersController,
               type: :request,
               vcr: { cassette_name: 'green_lanes/check_your_answers' } do
  describe 'GET #new' do
    before { make_request }

    let(:make_request) do
      get green_lanes_check_your_answers_path(
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
        t: timestamp,
      )
    end

    let(:timestamp) { Time.zone.now.to_i }

    it 'responds with status code :ok' do
      expect(response).to have_http_status(:ok), "Response body: #{response.body}"
    end

    it 'assigns the correct instance variables', :aggregate_failures do
      expect(assigns(:commodity_code)).to eq('4114109000')
      expect(assigns(:country_of_origin)).to eq('UA')
      expect(assigns(:moving_date)).to eq('29 May 2024')
      expect(assigns(:category_one_assessments)).to all(be_a(GreenLanes::CategoryAssessment))
      expect(assigns(:category_two_assessments)).to all(be_a(GreenLanes::CategoryAssessment))
      expect(assigns(:answers)).not_to be_nil
      expect(assigns(:c1ex)).to eq('true')
      expect(assigns(:c2ex)).to eq('false')
    end

    it 'renders the new template', :aggregate_failures do
      expect(response).to render_template('green_lanes/check_your_answers/show')
      expect(response).to render_template('green_lanes/shared/_about_your_goods_card')
      expect(response).to render_template('green_lanes/check_your_answers/_category_exemptions')
    end

    context 'when the page has expired' do
      let(:timestamp) { Time.zone.now.to_i - 11.hours }

      it 'redirects to the start page' do
        expect(make_request).to redirect_to green_lanes_start_path
      end
    end
  end
end
