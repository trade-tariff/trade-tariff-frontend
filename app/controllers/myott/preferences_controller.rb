module Myott
  class PreferencesController < MyottController
    before_action :authenticate

    def new
      delete_session_data
    end

    def create
      case params[:preference]
      when 'selectChapters'
        session[:all_tariff_updates] = false
        redirect_to edit_myott_preferences_path
      when 'allChapters'
        session_chapters.delete
        session[:all_tariff_updates] = true
        redirect_to myott_check_your_answers_path
      else
        flash.now[:error] = 'Select a subscription preference to continue'
        flash.now[:select_error] = 'Select an option to continue'
        render :new
      end
    end

    def edit
      @all_sections_chapters = session_chapters.all_sections_chapters
      @selected_chapters = session_chapters.selected_chapters
    end

    def update
      session[:all_tariff_updates] = false

      if params[:chapter_ids].blank?
        session[:chapter_ids] = []
        flash[:error] = 'Select the chapters you want tariff updates about.'
        redirect_to edit_myott_preferences_path and return
      else
        session[:chapter_ids] = params[:chapter_ids]
        redirect_to myott_check_your_answers_path
      end
    end

  private

    def delete_session_data
      session_chapters.delete
    end

    def session_chapters
      @session_chapters ||= SessionChaptersDecorator.new(session)
    end
  end
end
