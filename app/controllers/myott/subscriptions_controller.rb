module Myott
  class SubscriptionsController < MyottController
    before_action :authenticate, except: %i[start invalid]

    def start; end

    def invalid
      redirect_to myott_path if current_user.present?
    end

    def show
      return redirect_to new_myott_preferences_path unless current_user.stop_press_subscription

      session[:chapter_ids] = current_user.chapter_ids&.split(',')
      session[:chapter_ids] ||= session_chapters.all_chapters.map(&:to_param)

      set_selected_chapters
    end

    def check_your_answers
      redirect_to myott_path and return if session[:chapter_ids].blank?

      set_selected_chapters
    end

    def subscribe
      chapter_ids = if session[:all_tariff_updates]
                      ''
                    else
                      session[:chapter_ids].join(',')
                    end

      if User.update(cookies[:id_token], chapter_ids: chapter_ids, stop_press_subscription: 'true')
        session_chapters.delete
        redirect_to myott_confirmation_path and return
      end

      flash[:error] = 'There was an error updating your subscription. Please try again.'
      redirect_to myott_check_your_answers_path
    end

    def confirmation
      redirect_to myott_path unless current_user.stop_press_subscription
    end

  private

    def set_selected_chapters
      @selected_chapters_heading = session_chapters.selected_chapters_heading
      @selected_sections_chapters = session_chapters.selected_sections_chapters
    end

    def session_chapters
      @session_chapters ||= SessionChaptersDecorator.new(session)
    end
  end
end
