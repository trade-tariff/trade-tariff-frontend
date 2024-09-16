require 'spec_helper'

RSpec.describe GreenLanes::ApplicableExemptionsController,
               type: :request,
               vcr: { cassette_name: 'green_lanes/applicable_exemptions' } do
  subject { make_request && response }

  let(:commodity_code) { '4114109000' }
  let(:country_of_origin) { 'UA' }
  let(:moving_date) { '2024-05-29' }

  describe 'GET #new' do
    let(:make_request) do
      get green_lanes_applicable_exemptions_path(category: '1',
                                                 commodity_code:,
                                                 country_of_origin:,
                                                 moving_date:,
                                                 t: timestamp)
    end

    let(:timestamp) { Time.zone.now.to_i }

    it { is_expected.to have_http_status :ok }
    it { is_expected.to have_attributes content_type: %r{text/html} }

    it { is_expected.to render_template(:cat_1_exemptions_questions) }

    context 'when the page has expired' do
      let(:timestamp) { Time.zone.now.to_i - 11.hours }

      it { is_expected.to redirect_to green_lanes_start_path }
    end
  end

  describe 'POST #create' do
    before do
      allow(Time).to receive(:now).and_return(fixed_now)
    end

    let(:make_request) do
      post green_lanes_applicable_exemptions_path, params: {
        exemptions: {
          category_assessment_a6b633a7b098132ec45c036d0e14713a: ['', 'Y997'],
          category_assessment_18fcbb5b75781f8a676bd84dae9c170e: ['', 'none'],
        },
        category: '1',
        commodity_code:,
        country_of_origin:,
        moving_date:,
      }
    end

    let(:fixed_now) { Time.zone.now }

    it { is_expected.to have_http_status :redirect }

    it do
      expect(make_request).to redirect_to(
        green_lanes_check_your_answers_path({
          ans: {
            '1': {
              '18fcbb5b75781f8a676bd84dae9c170e' => %w[none],
              'a6b633a7b098132ec45c036d0e14713a' => %w[Y997],
            },
          },
          c1ex: false,
          category: '1',
          commodity_code: '4114109000',
          country_of_origin: 'UA',
          moving_date: '2024-05-29',
          t: fixed_now.to_i,
        }),
      )
    end
  end
end
