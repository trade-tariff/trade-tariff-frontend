require 'spec_helper'

RSpec.describe FindCommoditiesController, type: :request do
  subject { response }

  describe 'GET #show' do
    include_context 'with latest news stubbed'
    include_context 'with news updates stubbed'

    context 'without search params' do
      before { get find_commodity_path }

      it { is_expected.to have_http_status :ok }
      it { is_expected.to have_attributes content_type: %r{text/html} }
      it { is_expected.not_to have_attributes body: %r{There is a problem} }
    end

    context 'with valid search params' do
      before { get find_commodity_path(q: 'some search term', day: '1', month: '12', year: '2022') }

      it { is_expected.to redirect_to perform_search_path(q: 'some search term') }
    end

    context 'with invalid date params' do
      before { get find_commodity_path(q: 'valid term', day: '0', month: '12', year: '2022') }

      it { is_expected.to have_http_status :ok }
      it { is_expected.to have_attributes content_type: %r{text/html} }
      it { is_expected.to have_attributes body: %r{There is a problem} }
    end
  end
end
