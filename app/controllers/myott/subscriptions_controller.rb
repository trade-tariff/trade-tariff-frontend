module Myott
  class SubscriptionsController < MyottController
    before_action :disable_search_form,
                  :disable_switch_service_banner,
                  :disable_last_updated_footnote

    before_action :sections_chapters, only: %i[chapter_selection check_your_answers]

    def dashboard
      # TODO: Persist the user object
      @email = current_user&.fetch('email') || 'not_logged_in@email.com'
      session[:chapter_ids] = nil
    end

    def chapter_selection
      selected_chapter_ids = Array(session[:chapter_ids])
      @selected_chapters = all_chapters.select { |chapter| selected_chapter_ids.include?(chapter.to_param) }
    end

    def check_your_answers
      @all_tariff_updates = params[:all_tariff_updates] == 'true'
      selected_ids = @all_tariff_updates ? all_chapters.map(&:to_param) : Array(params[:chapter_ids])

      if selected_ids.empty?
        flash.now[:error] = 'Select the chapters you want tariff updates about.'
        @selected_chapters = []
        render :chapter_selection
        return
      end

      session[:chapter_ids] = selected_ids
      @selected_chapters = all_chapters.select { |chapter| selected_ids.include?(chapter.to_param) }
    end

    def preference_selection; end

    def set_preferences
      selection = params[:preference]

      case selection
      when 'selectChapters'
        redirect_to myott_chapter_selection_path
      when 'allChapters'
        redirect_to myott_check_your_answers_path(all_tariff_updates: true)
      else
        flash.now[:error] = 'Please select an option.'
        render :preference_selection
      end
    end

    private

    def all_chapters
      sections_chapters.values.flatten
    end

    def sections_chapters
      @sections_chapters ||= Rails.cache.fetch('sections_chapters', expires_in: 1.day) do
        Section.all.each_with_object({}) do |section, hash|
          chapters = Section.find(section.resource_id).chapters
          hash[section] = chapters
        end
      end
    end
  end
end
