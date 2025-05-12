module Myott
  class SubscriptionsController < ApplicationController
    before_action :disable_search_form,
                  :disable_switch_service_banner,
                  :disable_last_updated_footnote,
                  :cache_sections_chapters

    def dashboard
      @email = 'test@email.com'
      session[:chapter_ids] = nil
      flash[:error] = nil
    end

    def chapter_selection
      @selected_chapter_ids = Array(session[:chapter_ids])
      all_chapters = @sections_chapters.values.flatten
      @selected_chapters = all_chapters.select { |chapter| @selected_chapter_ids.include?(chapter.to_param) }
    end

    def check_your_answers
      selected_ids = Array(params[:chapter_ids])

      if selected_ids.empty?
        flash[:error] = 'Select the chapters you want tariff updates about.'
        @selected_chapters = []
        render :chapter_selection
        return
      else
        flash[:error] = nil
      end

      session[:chapter_ids] = params[:chapter_ids]

      all_chapters = @sections_chapters.values.flatten
      @selected_chapters = all_chapters.select { |chapter| selected_ids.include?(chapter.to_param) }
    end

    def remove_chapter_selection
      session[:chapter_ids] = Array(session[:chapter_ids]) - [params[:chapter_id]]
      head :ok
    end

    private

    def cache_sections_chapters
      @sections_chapters = Rails.cache.fetch('sections_chapters', expires_in: 1.hour) do
        Section.all.each_with_object({}) do |section, hash|
          chapters = Section.find(section.resource_id).chapters
          hash[section] = chapters
        end
      end
    end
  end
end
