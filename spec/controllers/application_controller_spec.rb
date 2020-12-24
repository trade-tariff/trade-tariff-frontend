require 'spec_helper'

describe ApplicationController, type: :controller do
  describe "behaviour for all subclasses" do
    controller do
      def index
        render plain: "Jabberwocky"
      end
    end

    describe "caching" do
      before do
        get :index
      end

      it "should have a max-age of 2 hours" do
        expect(response.headers["Cache-Control"]).to include "max-age=7200"
      end

      it "should have a public directive" do
        expect(response.headers["Cache-Control"]).to include "public"
      end

      it "should have a stale-if-error of 1 day" do
        expect(response.headers["Cache-Control"]).to include "stale-if-error=86400"
      end

      it "should have a stale-while-revalidate of 1 day" do
        expect(response.headers["Cache-Control"]).to include "stale-while-revalidate=86400"
      end
    end
  end

  describe '#preprocess_raw_params' do
    before do
      ENV['BREXIT_DATE'] = (Date.today + 5.days).to_s
      ENV['ALLOW_SEARCH'] = nil
      allow(TradeTariffFrontend).to receive(:block_searching_past_brexit?) { true }
    end

    after do
      ENV['BREXIT_DATE'] = nil
      ENV['ALLOW_SEARCH'] = 'true'
    end

    context 'when search date is not valid' do
      before do
        allow(controller).to receive(:params).and_return({year: '2019', month: '13', day: '54'})
      end

      it "does not add a flash message" do
        controller.send(:preprocess_raw_params)
        expect(controller.flash[:alert]).to_not match(/Sorry/)
      end
    end

    context 'when search date is valid' do
      before do
        date  = Date.today + 8.days
        allow(controller).to receive(:params).and_return({year: date.year, month: date.month, day: date.day})
      end

      it "adds a flash message" do
        controller.send(:preprocess_raw_params)
        expect(controller.flash[:alert]).to match(/Sorry/)
      end
    end
  end
end
