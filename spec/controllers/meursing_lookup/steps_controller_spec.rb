require 'spec_helper'

RSpec.describe MeursingLookup::StepsController, type: :controller do
  subject { response }

  describe 'GET #show' do
    shared_examples 'a request to GET a meursing lookup step' do |step_id, step_class|
      before { get :show, params: { id: step_id } }

      it { is_expected.to have_http_status :success }
      it { is_expected.to render_template 'meursing_lookup/steps/show' }
      it { expect(assigns[:current_step]).to be_a(step_class) }
      it { expect(session[:meursing_lookup]).to be_blank }
    end

    it_behaves_like 'a request to GET a meursing lookup step', :start, MeursingLookup::Steps::Start
    it_behaves_like 'a request to GET a meursing lookup step', :starch, MeursingLookup::Steps::Starch
    it_behaves_like 'a request to GET a meursing lookup step', :sucrose, MeursingLookup::Steps::Sucrose
    it_behaves_like 'a request to GET a meursing lookup step', :milk_fat, MeursingLookup::Steps::MilkFat
    it_behaves_like 'a request to GET a meursing lookup step', :milk_protein, MeursingLookup::Steps::MilkProtein
    it_behaves_like 'a request to GET a meursing lookup step', :review_answers, MeursingLookup::Steps::ReviewAnswers
    it_behaves_like 'a request to GET a meursing lookup step', :end, MeursingLookup::Steps::End
  end

  describe 'PATCH #update' do
    subject(:do_response) { patch :update, params: params }

    before { do_response }

    shared_examples 'a request to PATCH a meursing lookup step' do |step_id, step_klass, next_step_id|
      let(:params) do
        {
          id: step_id,
          "meursing_lookup_steps_#{step_id}" => { step_id => answer },
        }
      end

      context 'with a valid answer' do
        let(:answer) { '0 - 4.99' }

        it { expect(session.dig('meursing_lookup', step_id.to_s)).to eq(answer) }
        it { is_expected.to redirect_to meursing_lookup_step_path(next_step_id.to_s) }
        it { expect(assigns[:current_step]).to be_a(step_klass) }
      end

      context 'with an invalid answer' do
        let(:answer) { '' }

        it { is_expected.to have_http_status(:success) }
        it { expect(assigns[:current_step].errors.messages[step_id]).not_to be_blank }
        it { expect(session.dig('meursing_lookup', step_id.to_s)).to eq(nil) }
        it { is_expected.to render_template('meursing_lookup/steps/show') }
        it { expect(assigns[:current_step]).to be_a(step_klass) }
      end
    end

    it_behaves_like 'a request to PATCH a meursing lookup step', :starch, MeursingLookup::Steps::Starch, :sucrose
    it_behaves_like 'a request to PATCH a meursing lookup step', :sucrose, MeursingLookup::Steps::Sucrose, :milk_fat
    it_behaves_like 'a request to PATCH a meursing lookup step', :milk_fat, MeursingLookup::Steps::MilkFat, :milk_protein
    it_behaves_like 'a request to PATCH a meursing lookup step', :milk_protein, MeursingLookup::Steps::MilkProtein, :review_answers

    describe 'when patching a start step' do
      let(:params) { { id: :start } }

      it { expect(assigns[:current_step]).to be_a(MeursingLookup::Steps::Start) }
      it { is_expected.to redirect_to meursing_lookup_step_path('starch') }
    end

    describe 'when patching a review_answers step' do
      let(:params) { { id: :review_answers } }

      it { expect(assigns[:current_step]).to be_a(MeursingLookup::Steps::ReviewAnswers) }
      it { is_expected.to redirect_to meursing_lookup_step_path('end') }
    end
  end
end
