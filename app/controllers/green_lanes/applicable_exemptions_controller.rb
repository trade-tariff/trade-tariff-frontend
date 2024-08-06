module GreenLanes
  class ApplicableExemptionsController < ApplicationController
    include GreenLanesHelper

    before_action :check_green_lanes_enabled,
                  :disable_switch_service_banner,
                  :disable_search_form

    def new
      @check_your_answers_data = CheckYourAnswersData.new(parse_json_params(params[:check_your_answers_data]))
      @exemptions_form = exemptions_form

      render_exemptions_questions
    end

    def create
      @check_your_answers_data = CheckYourAnswersData.new(parse_json_params(params[:check_your_answers_data]))
      @exemptions_form = exemptions_form

      if @exemptions_form.valid?
        @check_your_answers_data.exemptions_answers_data = @exemptions_form.attributes

        next_page = determine_next_page
        redirect_to handle_next_page(next_page, @check_your_answers_data.attributes)
      else
        render_exemptions_questions
      end
    end

    private

    # Category assessment methods
    def category_assessments
      @category_assessments ||= determine_category.public_send("cat#{category}_with_exemptions")
    end

    def determine_category
      @determine_category ||= DetermineCategory.new(goods_nomenclature)
    end

    # Goods nomenclature methods
    def goods_nomenclature
      @goods_nomenclature ||= FetchGoodsNomenclature.new(@check_your_answers_data.moving_requirements_data).call
    end

    # Form handling methods
    def exemptions_form
      ApplicableExemptionsForm.new(exemptions_params)
    end

    def exemptions_params
      {
        'category_assessments' => category_assessments,
        'answers' => exemptions_answers,
      }
    end

    def exemptions_answers
      return {} unless params.key?(:exemptions)

      params.require(:exemptions).permit(applicable_answers).to_hash
    end

    def applicable_answers
      category_assessments.each_with_object({}) do |ca, acc|
        acc[ca.id] = []
      end
    end

    # View rendering methods
    def render_exemptions_questions
      render "cat_#{@category}_exemptions_questions"
    end

    # Parameter handling methods
    def goods_nomenclature_params
      params.permit(:commodity_code, :country_of_origin, :moving_date)
    end

    def moving_requirements_params
      params.require(:green_lanes_moving_requirements_form).permit(
        :commodity_code,
        :country_of_origin,
        :moving_date,
      )
    end

    def category
      @category ||= Integer(params[:category])
    end

    def determine_next_page
      GreenLanes::DetermineNextPage.new(@goods_nomenclature)
                                   .next(cat_1_exemptions_apply: applicable_exemptions_result_params[:c1ex],
                                         cat_2_exemptions_apply: applicable_exemptions_result_params[:c2ex])
    end

    # Path helper methods
    def applicable_exemptions_path
      green_lanes_applicable_exemptions_path(
        category:,
        commodity_code: params[:commodity_code],
        moving_date: params[:moving_date],
        country_of_origin: params[:country_of_origin],
        c1ex: params[:c1ex].present? ? params[:c1ex] == 'true' : nil,
        ans: passed_exemption_answers[:ans],
      )
    end

    def applicable_exemptions_result_params
      {
        commodity_code: params[:commodity_code],
        country_of_origin: params[:country_of_origin],
        moving_date: params[:moving_date],
      }.merge(exemptions_results_params)
    end

    def exemptions_results_params
      current_category_result = if params[:category] == '1'
                                  { c1ex: @exemptions_form.exempt? }
                                else
                                  { c2ex: @exemptions_form.exempt? }
                                end

      previous_category_result = if params[:c1ex].present?
                                   { c1ex: params[:c1ex] }
                                 else
                                   {}
                                 end

      merged_params = current_category_result.merge(previous_category_result)
      merged_params[:c1ex] = merged_params[:c1ex].to_s == 'true' if merged_params[:c1ex].present?
      merged_params[:c2ex] = merged_params[:c2ex].to_s == 'true' if merged_params[:c2ex].present?
      merged_params
    end

    def handle_next_page(next_page, check_your_answers_data)
      uri = URI(next_page)
      path = uri.path
      next_page_query = if uri.query
                          CGI.parse(uri.query).transform_values(&:first)
                        else
                          {}
                        end

      query = {
        commodity_code: params[:commodity_code],
        country_of_origin: params[:country_of_origin],
        moving_date: params[:moving_date],
        category: params[:category],
        check_your_answers_data:,
      }
        .merge(exemptions_results_params)
        .merge(next_page_query)
        .merge(passed_exemption_answers)
        .deep_symbolize_keys

      "#{path}?#{query.to_query}"
    end

    def passed_exemption_answers
      new_answers = {
        ans: {
          category => @exemptions_form.presented_answers,
        },
      }

      old_answers = if params[:ans].present?
                      params.require(:ans).permit("1": {}).to_hash
                    else
                      {}
                    end

      new_answers.deep_merge(ans: old_answers)
    end

    helper_method :applicable_exemptions_path
  end
end
