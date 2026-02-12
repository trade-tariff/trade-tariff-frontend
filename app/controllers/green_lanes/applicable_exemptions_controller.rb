module GreenLanes
  class ApplicableExemptionsController < ApplicationController
    include GreenLanesHelper

    include Concerns::ExpirableUrl

    before_action :check_green_lanes_enabled,
                  :disable_switch_service_banner,
                  :disable_search_form

    before_action :page_has_not_expired, only: %i[new]

    def new
      @exemptions_form = build_exemptions_form
      @back_link_path = back_link_path_for_current_page

      render_exemptions_questions(:ok)
    end

    def create
      @exemptions_form = build_exemptions_form

      if @exemptions_form.valid?
        next_page = determine_next_page
        redirect_to handle_next_page(next_page)
      else
        @back_link_path = back_link_path_for_current_page

        render_exemptions_questions(:unprocessable_entity)
      end
    end

    private

    def back_link_params
      params.permit(
        :commodity_code,
        :country_of_origin,
        :moving_date,
        :c1ex,
        :c2ex,
        ans: {},
      )
    end

    def back_link_path_for_current_page
      BackLinkPath.new(params: back_link_params,
                       category_one_assessments_without_exemptions: candidate_categories.cat1_without_exemptions,
                       category_two_assessments_without_exemptions: candidate_categories.cat2_without_exemptions).call
    end

    def parsed_ans(ans_param)
      return ans_param unless ans_param.is_a?(String)

      JSON.parse(ans_param)
    end

    # Category assessment methods
    def category_assessments
      @category_assessments ||= candidate_categories.public_send("cat#{category}_with_exemptions")
    end

    def candidate_categories
      @candidate_categories ||= DetermineCandidateCategories.new(goods_nomenclature)
    end

    # Goods nomenclature methods
    def goods_nomenclature
      @goods_nomenclature ||= FetchGoodsNomenclature.new(goods_nomenclature_params).call
    end

    # Form handling methods
    def build_exemptions_form
      ApplicableExemptionsForm.new(exemptions_params)
    end

    def exemptions_params
      {
        'category_assessments' => category_assessments,
        'answers' => exemptions_answers,
      }
    end

    def exemptions_answers
      params.fetch(:exemptions, {}).permit(applicable_answers).to_hash
    end

    def applicable_answers
      category_assessments.each_with_object({}) do |ca, acc|
        acc[ca.id] = []
      end
    end

    # View rendering methods
    def render_exemptions_questions(status)
      render "cat_#{@category}_exemptions_questions", locals: { back_link_path: @back_link_path }, status:
    end

    # Parameter handling methods
    def goods_nomenclature_params
      params.permit(:commodity_code, :country_of_origin, :moving_date)
    end

    def category
      @category ||= params[:category].to_i
    end

    def determine_next_page
      GreenLanes::DetermineNextPage.new(goods_nomenclature).next(
        cat_1_exemptions_apply: applicable_exemptions_result_params[:c1ex],
        cat_2_exemptions_apply: applicable_exemptions_result_params[:c2ex],
      )
    end

    # Path helper methods
    def applicable_exemptions_path
      green_lanes_category_exemptions_path(
        category:,
        commodity_code: params[:commodity_code],
        moving_date: params[:moving_date],
        country_of_origin: params[:country_of_origin],
        c1ex: params[:c1ex].present? ? params[:c1ex] == 'true' : nil,
        ans: passed_exemption_answers[:ans],
        t: Time.zone.now.to_i,
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
      current_result = { category == 1 ? :c1ex : :c2ex => @exemptions_form.exempt? }
      previous_result = params[:c1ex].present? ? { c1ex: params[:c1ex] } : {}
      merged_params = current_result.merge(previous_result)
      merged_params.transform_values! { |v| v.to_s == 'true' } if merged_params.present?
      merged_params
    end

    def handle_next_page(next_page)
      uri = URI(next_page)
      path = uri.path
      next_page_query = if uri.query
                          Rack::Utils.parse_query(uri.query)
                        else
                          {}
                        end

      query = {
        commodity_code: params[:commodity_code],
        country_of_origin: params[:country_of_origin],
        moving_date: params[:moving_date],
        category: params[:category],
      }
        .merge(exemptions_results_params)
        .merge(next_page_query)
        .merge(passed_exemption_answers)
        .merge(t: Time.zone.now.to_i)
        .deep_symbolize_keys

      "#{path}?#{query.to_query}"
    end

    def passed_exemption_answers
      new_answers = { ans: { category => @exemptions_form.presented_answers } }
      old_answers = params[:ans].present? ? params.require(:ans).permit("1": {}).to_hash : {}
      new_answers.deep_merge(ans: old_answers)
    end

    helper_method :applicable_exemptions_path
  end
end
