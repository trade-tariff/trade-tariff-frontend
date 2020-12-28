require 'spec_helper'

describe ApplicationController, type: :controller do
  describe 'behaviour for all subclasses' do
    controller do
      def index
        render plain: 'Jabberwocky'
      end
    end

    describe 'caching' do
      before do
        get :index
      end

      it 'has a max-age of 2 hours' do
        expect(response.headers['Cache-Control']).to include 'max-age=7200'
      end

      it 'has a public directive' do
        expect(response.headers['Cache-Control']).to include 'public'
      end

      it 'has a stale-if-error of 1 day' do
        expect(response.headers['Cache-Control']).to include 'stale-if-error=86400'
      end

      it 'has a stale-while-revalidate of 1 day' do
        expect(response.headers['Cache-Control']).to include 'stale-while-revalidate=86400'
      end
    end
  end
end
