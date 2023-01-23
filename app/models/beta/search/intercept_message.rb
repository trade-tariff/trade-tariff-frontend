require 'api_entity'

module Beta
  module Search
    class InterceptMessage
      include ApiEntity

      attr_accessor :term,
                    :message,
                    :formatted_message

      def html_message
        Rinku.auto_link(
          Govspeak::Document.new(formatted_message, sanitize: false).to_html,
        ).html_safe
      end
    end
  end
end
