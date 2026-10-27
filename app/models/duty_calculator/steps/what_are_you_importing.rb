module DutyCalculator
  module Steps
    class WhatAreYouImporting < Steps::Base
      attribute :search_term, :string

      validate :search_term_present

      def search_term
        super&.strip || user_session.what_are_you_importing
      end

      def save!
        user_session.what_are_you_importing = search_term.strip
      end

      def previous_step_path
        homepage_import_details_path
      end

    private

      def search_term_present
        return if search_term.present?

        errors.add(:search_term, 'Enter a search term')
      end
    end
  end
end
