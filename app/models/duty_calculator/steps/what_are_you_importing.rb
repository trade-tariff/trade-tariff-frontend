module DutyCalculator
  module Steps
    class WhatAreYouImporting < Steps::Base
      MAX_SESSION_SEARCH_TERM_BYTES = 512

      def self.session_search_term_limit_error = "Search term must be #{MAX_SESSION_SEARCH_TERM_BYTES} bytes or fewer"

      attribute :search_term, :string

      validates :search_term, presence: { message: 'Enter a search term' }
      validate :search_term_fits_session_cookie

      def search_term = super&.to_s&.strip || user_session.what_are_you_importing

      def save! = user_session.what_are_you_importing = search_term.strip

      def previous_step_path = homepage_import_details_path

    private

      def search_term_fits_session_cookie
        errors.add(:search_term, self.class.session_search_term_limit_error) if search_term.present? &&
          search_term.bytesize > MAX_SESSION_SEARCH_TERM_BYTES
      end
    end
  end
end
