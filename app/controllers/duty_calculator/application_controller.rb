module DutyCalculator
  class ApplicationController < ::ApplicationController
    before_action :user_session, :disable_switch_service_banner, :disable_search_form, :disable_last_updated_footnote

    after_action :no_store_cache

    def no_store_cache
      expires_in 0, public: false, stale_while_revalidate: 0, stale_if_error: 0
    end

  protected

    def user_session
      @user_session ||= UserSession.build(session)
    end
  end
end
