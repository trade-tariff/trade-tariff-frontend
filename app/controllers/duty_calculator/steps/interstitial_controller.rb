module DutyCalculator
  module Steps
    class InterstitialController < BaseController
      helper_method :title

      def show
        @step = Steps::Interstitial.new
      end

      protected

      def title
        return t('page_titles.interstitial.gb_to_ni') if user_session.gb_to_ni_route?

        t('page_titles.interstitial.default')
      end
    end
  end
end
