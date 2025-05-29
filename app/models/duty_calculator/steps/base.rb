module DutyCalculator
  module Steps
    class Base
      include ActiveModel::Model
      include ActiveModel::Attributes
      include Rails.application.routes.url_helpers
      include CommodityHelper
      include UkimsHelper

      STEPS_TO_REMOVE_FROM_SESSION = [].freeze

      def initialize(attributes = {})
        attributes = HashWithIndifferentAccess.new(attributes)

        if attributes.except(:measure_type_id, :"import_date(3i)", :"import_date(2i)", :"import_date(1i)").empty?
          clean_user_session
        end

        super(attributes)
      end

      def self.id
        name.split('::').last.underscore
      end

      protected

      def next_step_path
        raise NotImplementedError
      end

      def previous_step_path
        raise NotImplementedError
      end

      def user_session
        UserSession.get
      end

      private

      def clean_user_session
        user_session.remove_step_ids(self.class::STEPS_TO_REMOVE_FROM_SESSION) unless user_session.nil?
      end
    end
  end
end
