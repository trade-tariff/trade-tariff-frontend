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
      @moving_requirements_form = MovingRequirementsForm.new(form_params)

      render 'edit'
    end

    def update
      flash[:error] = nil

      @moving_requirements_form = MovingRequirementsForm.new(moving_requirements_params)
      form = @moving_requirements_form

      if form.valid?
        redirect_to result_green_lanes_check_moving_requirements_path(green_lanes_moving_requirements_form: form_params)
      else
        render 'edit', status: :unprocessable_entity
      end
    end

    def result
      goods_nomenclature = find_goods_nomenclature

      @commodity_code = goods_nomenclature.goods_nomenclature_item_id
      @country_of_origin = moving_requirements_params[:country_of_origin] || GeographicalArea::ERGA_OMNES
      @country_description = GeographicalArea.find(@country_of_origin).description
      @moving_date = moving_requirements_params[:moving_date]
      @determine_categories = GreenLanes::DetermineCategory.new(goods_nomenclature)

      @categories = @determine_categories.categories

      next_page = DetermineNextPage.new(goods_nomenclature).next

      case next_page
      when :result_cat_1
        render 'result_cat_1'
      when :result_cat_2
        render 'result_cat_2'
      when :result_cat_3
        render 'result_cat_3'
      when :cat_1_exemptions_questions
        redirect_to cat_1_questions_green_lanes_check_moving_requirements_edit_path
      when :cat_2_exemptions_questions
        redirect_to cat_2_questions_green_lanes_check_moving_requirements_edit_path
      end
    end

    def cat_1_exemptions_questions
      @goods_nomenclature = GreenLanes::GoodsNomenclature.find(
        questions_page_params[:commodity_code],
        { filter: { geographical_area_id: questions_page_params[:country_of_origin] } },
        { authorization: TradeTariffFrontend.green_lanes_api_token },
      )
    end

    def cat_1_exemptions_questions_edit
      # cc= '4114109000'
      # country_of_origin= 'UA'
      # moving_date= '2024-07-15'

      # goods_nomenclature = GreenLanes::GoodsNomenclature.find(cc,
      #   { filter: { geographical_area_id: country_of_origin, moving_date: moving_date } },
      #   { authorization: TradeTariffFrontend.green_lanes_api_token },
      # )

      goods_nomenclature = find_goods_nomenclature

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

    def cat_2_exemptions_questions_edit
      goods_nomenclature = find_goods_nomenclature

      @category_assessments = DetermineCategory.new(goods_nomenclature).cat1_with_exemptions
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

    def questions_page_params
      params.permit(:commodity_code, :country_of_origin, :moving_date)
    end

    def form_params
      { commodity_code: @commodity_code, country_of_origin: params[:country_of_origin], moving_date: params[:moving_date] }
    end

    def find_goods_nomenclature
      GreenLanes::GoodsNomenclature.find(
        moving_requirements_params[:commodity_code],
        { filter: { geographical_area_id: moving_requirements_params[:country_of_origin], moving_date: moving_requirements_params[:moving_date] } },
        { authorization: TradeTariffFrontend.green_lanes_api_token },
      )
    rescue StandardError => e
      Rails.logger.error "GoodsNomenclature API error: #{e.message}"
      nil
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
