module RulesOfOrigin
  module Steps
    class Cumulation < Base
      self.section = 'originating'

      def skipped?
        @wizard.find('not_wholly_obtained').skipped?
      end

      def scheme_details
        article = exporting? ? 'cumulation-export' : 'cumulation-import'
        chosen_scheme.article(article)&.content
      end

      def map_path
        File.join("/cumulation_maps/#{chosen_scheme.scheme_code}.png")
      end

      def available_cumulation_methods
        cumulation_methods.keys
      end

      def country_codes_to_names(cumulation_method)
        countries_by_code = GeographicalArea.all.index_by(&:id)

        cumulation_methods[cumulation_method].map do |country_code|
          case country_code 
          when 'EU'
            'the European Union Member States'
          when 'GB'
            'United Kingdom'
          else
            countries_by_code[country_code]&.description 
          end
        end
      end

      private

      def cumulation_methods
        chosen_scheme.cumulation_methods
      end
    end
  end
end
