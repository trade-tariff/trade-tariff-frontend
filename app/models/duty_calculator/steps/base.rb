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

      def import_date_step_path
        import_date_path(import_date_path_params_for_session)
      end

      private

      def import_date_path_params_for_session
        params_hash = { commodity_code: user_session.commodity_code }
        return params_hash if user_session.import_date.blank?

        params_hash.merge(
          day: user_session.import_date.day,
          month: user_session.import_date.month,
          year: user_session.import_date.year,
        )
      end

      def clean_user_session
        user_session.remove_step_ids(self.class::STEPS_TO_REMOVE_FROM_SESSION) unless user_session.nil?
      end
    end
  end
end
