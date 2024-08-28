module GreenLanes
  class BackLinkPath
    def initialize(params:,
                   category_one_assessments_without_exemptions:,
                   category_two_assessments_without_exemptions:)
      @params = params
      @category_one_assessments_without_exemptions = category_one_assessments_without_exemptions
      @category_two_assessments_without_exemptions = category_two_assessments_without_exemptions
    end

    def call
      ans = @params[:ans]
      category = determine_category(ans)

      base_params = {
        commodity_code: @params[:commodity_code],
        country_of_origin: @params[:country_of_origin],
        moving_date: @params[:moving_date],
      }

      if category == 2 && @category_two_assessments_without_exemptions.empty?
        # Remvoing the old answers for the back link path
        ans.delete('2')

        Rails.application.routes.url_helpers
          .new_green_lanes_applicable_exemptions_path(base_params.merge(category:,
                                                                        ans:,
                                                                        c1ex: @params[:c1ex]))
      elsif ans.nil? || ans['1'].nil? || @category_one_assessments_without_exemptions.present?
        Rails.application.routes.url_helpers
          .new_green_lanes_moving_requirements_path(base_params)
      else
        Rails.application.routes.url_helpers
          .new_green_lanes_applicable_exemptions_path(base_params.merge(
                                                        category:,
                                                        ans: {},
                                                      ))
      end
    end

    private

    def determine_category(answers)
      if answers.nil? || @category_two_assessments_without_exemptions.present?
        1
      elsif answers['2'].present?
        2
      else
        1
      end
    end
  end
end
