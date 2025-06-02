module Myott
  class SubscriptionsController < MyottController
    before_action :disable_search_form,
                  :disable_switch_service_banner,
                  :disable_last_updated_footnote

    before_action :sections_chapters, only: %i[chapter_selection check_your_answers]

    def start; end

    def dashboard
      @email = current_user&.email || 'not_logged_in@email.com'
      subscribed_to_stop_press = current_user&.stop_press_subscription || false

      return redirect_to myott_preference_selection_path unless subscribed_to_stop_press

      session[:chapter_ids] = if current_user&.chapter_ids&.split(',')&.any?
                                current_user&.chapter_ids&.split(',')
                              else
                                all_chapters.map(&:to_param)
                              end
      @selected_chapters = get_selected_chapters(Array(session[:chapter_ids]))
    end

    def set_preferences
      selection = params[:preference]

      case selection
      when 'selectChapters'
        redirect_to myott_chapter_selection_path
      when 'allChapters'
        redirect_to myott_check_your_answers_path(all_tariff_updates: true)
      else
        flash.now[:error] = 'Select a subscription preference to continue'
        flash.now[:select_error] = 'Select an option to continue'
        render :preference_selection
      end
    end

    def chapter_selection
      @selected_chapters = get_selected_chapters(Array(session[:chapter_ids]))
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
      @selected_chapters =  get_selected_chapters(Array(session[:chapter_ids]))
    end

    def preference_selection; end

    def subscribe
      if params[:all_tariff_updates] == 'true'
        session[:chapter_ids] = []
      end
      updated_user = User.update(cookies[:id_token], chapter_ids: session[:chapter_ids].join(','), stop_press_subscription: 'true')
      Rails.logger.info("User updated: #{updated_user.inspect}")
      if updated_user
        session.delete(:chapter_ids)
        session.delete(:all_tariff_updates)
        redirect_to myott_subscription_confirmation_path
      else
        flash[:error] = 'There was an error updating your subscription. Please try again.'
        @selected_chapters = get_selected_chapters(Array(session[:chapter_ids]))
        if params[:all_tariff_updates] == 'true'
          redirect_to myott_check_your_answers_path(all_tariff_updates: 'true')
        else
          render :check_your_answers
        end
      end
    end

    def subscription_confirmation
      @email = current_user&.email
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

    def ensure_subscription_in_progress
      redirect_to myott_path if session[:chapter_ids].nil?
    end

    def get_selected_chapters(selected_chapter_ids)
      all_chapters.select { |chapter| selected_chapter_ids.include?(chapter.to_param) }
    end
  end
end
