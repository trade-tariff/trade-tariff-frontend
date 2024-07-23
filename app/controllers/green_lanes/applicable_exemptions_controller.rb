module GreenLanes
  class ApplicableExemptionsController < ApplicationController
    include GreenLanesHelper

    before_action :check_green_lanes_enabled,
                  :disable_switch_service_banner,
                  :disable_search_form

    def new
      @exemptions_form = exemptions_form
      send("cat_#{category}_exemptions_questions")
    end

    def create
      @exemptions_form = exemptions_form

      if @exemptions_form.valid?
        raise 'TODO: next result page'
      else
        render "cat_#{category}_exemptions_questions"
      end
    end

    private

    def category_assessments
      @category_assessments ||= determine_category.public_send("cat#{category}_with_exemptions")
    end

    def cat_1_exemptions_questions
      render 'cat_1_exemptions_questions'
    end

    def cat_2_exemptions_questions
      render 'cat_2_exemptions_questions'
    end

    def moving_requirements_params
      params.require(:green_lanes_moving_requirements_form).permit(
        :commodity_code,
        :country_of_origin,
        :moving_date,
      )
    end

    def exemptions_params
      {
        'category_assessments' => category_assessments,
        'answers' => exemptions_answers,
      }
    end

    def exemptions_answers
      return {} unless params.key?(:exemptions)

      params.require(:exemptions).permit(applicable_answers)
    end

    def applicable_answers
      @category_assessments.each_with_object({}) do |ca, acc|
        acc[ca.id] = []
      end
    end

    def exemptions_form
      ApplicableExemptionsForm.new(exemptions_params)
    end

    def determine_category
      @determine_category ||= DetermineCategory.new(goods_nomenclature)
    end

    def goods_nomenclature
      @goods_nomenclature ||= GreenLanes::GoodsNomenclature.find(
        params[:commodity_code],
        {
          filter: {
            geographical_area_id: params[:country_of_origin],
            moving_date: params[:moving_date],
          },
          as_of: params[:moving_date],
        },
        { authorization: TradeTariffFrontend.green_lanes_api_token },
      )
    end

    def category
      @category ||= Integer(params[:category])
    end

    def applicable_exemptions_path
      green_lanes_applicable_exemptions_path(
        category: 1,
        commodity_code: params[:commodity_code],
        moving_date: params[:moving_date],
        country_of_origin: params[:country_of_origin],
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

      current_category_result.merge(previous_category_result)
    end

    helper_method :applicable_exemptions_path
  end
end
