module Myott
  class SubscriptionsController < ApplicationController
    before_action :disable_search_form,
                  :disable_switch_service_banner,
                  :disable_last_updated_footnote

    before_action :sections_chapters, only: %i[chapter_selection]

    def dashboard
      @email = 'test@email.com'
      session[:chapter_ids] = nil
    end

    def chapter_selection
      selected_chapter_ids = Array(session[:chapter_ids])
      @selected_chapters = all_chapters.select { |chapter| selected_chapter_ids.include?(chapter.to_param) }
    end

    def check_your_answers
      selected_ids = Array(params[:chapter_ids])

      if selected_ids.empty?
        flash.now[:error] = 'Select the chapters you want tariff updates about.'
        @selected_chapters = []
        render :chapter_selection
        return
      end

      session[:chapter_ids] = params[:chapter_ids]

      @selected_chapters = all_chapters.select { |chapter| selected_ids.include?(chapter.to_param) }
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
