module Myott
  class PreferencesController < MyottController
    def new
      session_chapters.delete
      @form = Myott::StopPressPreferenceForm.new
    end

    def create
      @form = Myott::StopPressPreferenceForm.new(preference_params)

      if @form.select_chapters?
        session[:all_tariff_updates] = false
        redirect_to edit_myott_stop_press_preferences_path and return
      elsif @form.all_chapters?
        session_chapters.delete
        session[:all_tariff_updates] = true
        redirect_to check_your_answers_myott_stop_press_path and return
      else
        render :new
      end
    end

    def edit
      @all_sections_chapters = session_chapters.all_sections_chapters
      @selected_chapters = session_chapters.selected_chapters
    end

    def update
      if params[:chapter_ids].blank?
        session_chapters.delete
        flash[:alert] = 'You must select at least one chapter.'
        redirect_to edit_myott_stop_press_preferences_path and return
      else
        session[:all_tariff_updates] = false
        session[:chapter_ids] = params[:chapter_ids]
        redirect_to check_your_answers_myott_stop_press_path and return
      end
    end

  private

    def preference_params
      params.fetch(:myott_stop_press_preference_form, {}).permit(:preference)
    end

    def session_chapters
      @session_chapters ||= SessionChaptersDecorator.new(session)
    end
  end
end
