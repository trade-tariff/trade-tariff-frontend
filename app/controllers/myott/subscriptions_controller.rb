module Myott
  class SubscriptionsController < MyottController
    before_action :all_sections_chapters, only: %i[chapter_selection check_your_answers]
    before_action :authenticate, except: %i[start invalid]

    def start; end

    def invalid
      if current_user.present?
        redirect_to myott_path
      end
    end

    def dashboard
      return redirect_to myott_preference_selection_path unless current_user.stop_press_subscription

      session[:chapter_ids] = if current_user.chapter_ids&.split(',')&.any?
                                current_user.chapter_ids&.split(',')
                              else
                                all_chapters.map(&:to_param)
                              end

      @amount_of_selected_chapters = get_amount_of_selected_chapters(Array(session[:chapter_ids]))
      @selected_sections_chapters = get_selected_sections_chapters(Array(session[:chapter_ids]))
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
      @amount_of_selected_chapters = get_amount_of_selected_chapters(Array(session[:chapter_ids]))
      @selected_sections_chapters = get_selected_sections_chapters(Array(session[:chapter_ids]))
    end

    def preference_selection
      session.delete(:chapter_ids)
    end

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
      @header = 'You have updated your subscription'
      @message = "When Stop Press updates are published by the UK Trade Tariff Service which relate to the chapters you have chosen, an email will be sent to <strong>#{current_user&.email}</strong>"
      render :confirmation
    end

    private

    def all_chapters
      all_sections_chapters.values.flatten
    end

    def all_sections_chapters
      @all_sections_chapters ||= Rails.cache.fetch('all_sections_chapters', expires_in: 1.day) do
        Section.all.each_with_object({}) do |section, hash|
          chapters = Section.find(section.resource_id).chapters
          hash[section] = chapters
        end
      end
    end

    def get_selected_chapters(selected_chapter_ids)
      get_selected_sections_chapters(selected_chapter_ids).values.flatten
    end

    def get_selected_sections_chapters(selected_chapter_ids)
      all_sections_chapters.each_with_object({}) do |(section, chapters), hash|
        selected_chapters = chapters.select do |chapter|
          selected_chapter_ids.include?(chapter.to_param)
        end

        hash[section] = selected_chapters if selected_chapters.any?
      end
    end

    def get_amount_of_selected_chapters(selected_chapter_ids)
      count = get_selected_chapters(selected_chapter_ids).count
      if count.zero? || count == all_chapters.count
        'all'
      else
        count
      end
    end
  end
end
