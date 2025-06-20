require 'action_view/helpers'

module Myott
  class SessionChaptersDecorator < SimpleDelegator
    include ActionView::Helpers::TextHelper

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

    def selected_chapters_heading
      count = selected_chapters.count
      amount = if count.zero? || count == all_chapters.count
                 'all chapters'
               else
                 pluralize(count, 'chapter')
               end

      "You have selected #{amount}"
    end

    def selected_chapters
      selected_sections_chapters.values.flatten
    end

    def selected_sections_chapters
      all_sections_chapters.each_with_object({}) do |(section, chapters), hash|
        selected_chapters = chapters.select do |chapter|
          self[:chapter_ids]&.include?(chapter.to_param)
        end

        hash[section] = selected_chapters if selected_chapters.any?
      end
    end

    def delete
      super(:chapter_ids)
      super(:all_tariff_updates)
    end
  end
end
