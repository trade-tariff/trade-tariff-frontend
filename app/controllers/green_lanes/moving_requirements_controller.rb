module GreenLanes
  class MovingRequirementsController < ApplicationController
    before_action :check_green_lanes_enabled,
                  :disable_switch_service_banner,
                  :disable_search_form

    def start
      @commodity_code = params[:commodity_code]
      render 'start'
    end

    def edit
      @commodity_code = params[:commodity_code]
      @moving_requirements_form = MovingRequirementsForm.new(commodity_code: @commodity_code,
                                                             country_of_origin: params[:country_of_origin],
                                                             moving_date: params[:moving_date])

      render 'edit'
    end

    def update
      flash[:error] = nil

      @moving_requirements_form = MovingRequirementsForm.new(moving_requirements_params)
      form = @moving_requirements_form

      if form.valid?
        redirect_to result_green_lanes_check_moving_requirements_path(
          green_lanes_moving_requirements_form: {
            commodity_code: form.commodity_code,
            country_of_origin: form.country_of_origin,
            moving_date: form.moving_date,
          },
        )
      else
        render 'edit', status: :unprocessable_entity
      end
    end

    def result
      # ========================================================
      # added to enable easy testing
      # next_page = :result_cat_1
      # @selected_exemptions = {"34"=>["Y997"], "82"=>["none"]}
      # moving_requirements_params = {
      #   "commodity_code" => "4114109000",
      #     "country_of_origin" => "UA",
      #     "moving_date" => "2024-07-16"
      # }.with_indifferent_access
      # ===================================================

      set_goods_nomenclature

      @commodity_code = goods_nomenclature.goods_nomenclature_item_id
      @country_of_origin = moving_requirements_params[:country_of_origin] || GeographicalArea::ERGA_OMNES
      @country_description = GeographicalArea.find(@country_of_origin).description
      @moving_date = moving_requirements_params[:moving_date]
      @determine_categories = GreenLanes::DetermineCategory.new(goods_nomenclature)
      @categories = @determine_categories.categories
      @selected_exemptions = params[:exemptions][:category_assessments_checked]

      # next_page = DetermineNextPage.new(goods_nomenclature).next

      if params[:check_your_answers]
        render next_page
      else
        handle_result_redirection(next_page)
      end
    end

    def check_your_answers
      set_goods_nomenclature

      @commodity_code = goods_nomenclature.goods_nomenclature_item_id
      @country_of_origin = params[:country_of_origin] || GeographicalArea::ERGA_OMNES
      @moving_date = params[:moving_date]
      @result = params[:result]
      @selected_exemptions= params[:selected_exemptions]
      @rejected_exemptions= {}

      @category_one_assessments = DetermineCategory.new(goods_nomenclature).cat1_with_exemptions
      @category_two_assessments = DetermineCategory.new(goods_nomenclature).cat2_with_exemptions

      render 'check_your_answers'
    end

    def cat_1_exemptions_questions
      set_goods_nomenclature(questions_page_params)

      @category_assessments = DetermineCategory.new(goods_nomenclature).cat1_with_exemptions
    end

    def cat_1_exemptions_questions_update
      selected_exemptions = params[:exemptions] || []

      if selected_exemptions.present?
        # next result page
      else
        flash[:error] = 'Not all exemption options selected.'
      end

      redirect_to some_path
    end

    def cat_2_exemptions_questions
      set_goods_nomenclature(questions_page_params)

      @category_assessments = DetermineCategory.new(goods_nomenclature).cat2_with_exemptions
    end

    def cat_2_exemptions_questions_update
      selected_exemptions = params[:exemptions] || []

      if selected_exemptions.present?
        # next result page
      else
        flash[:error] = 'Not all exemption options selected.'
      end

      redirect_to some_path
    end

    private

    def handle_result_redirection(next_page)
      redirection_params = {
        commodity_code: @commodity_code,
        country_of_origin: @country_of_origin,
        moving_date: @moving_date,
        selected_exemptions: @selected_exemptions,
        result: next_page
      }

      case next_page
      when :result_cat_1, :result_cat_2, :result_cat_3
        redirect_to check_your_answers_path(redirection_params)
      when :cat_1_exemptions_questions
        redirect_to cat_1_questions_path(redirection_params)
      when :cat_2_exemptions_questions
        redirect_to cat_2_questions_path(redirection_params)
      end
    end

    def set_goods_nomenclature(filter_params = moving_requirements_params)
      @goods_nomenclature = GreenLanes::GoodsNomenclature.find(
        filter_params[:commodity_code],
        { filter: { geographical_area_id: filter_params[:country_of_origin], moving_date: filter_params[:moving_date] } },
        { authorization: TradeTariffFrontend.green_lanes_api_token }
      )
    end

    def questions_page_params
      params.permit(:commodity_code, :country_of_origin, :moving_date)
    end

    def moving_requirements_params
      params.require(:green_lanes_moving_requirements_form).permit(
        :commodity_code,
        :country_of_origin,
        :moving_date,
      )
    end

    def check_green_lanes_enabled
      unless TradeTariffFrontend.green_lanes_enabled?
        raise TradeTariffFrontend::FeatureUnavailable
      end
    end
  end
end
