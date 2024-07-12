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
      goods_nomenclature = GreenLanes::GoodsNomenclature.find(
        moving_requirements_params[:commodity_code],
        { filter: { geographical_area_id: moving_requirements_params[:country_of_origin] } },
        { authorization: TradeTariffFrontend.green_lanes_api_token },
      )

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
        redirect_to cat_1_questions_green_lanes_check_moving_requirements_path(
          commodity_code: @commodity_code,
          country_of_origin: @country_of_origin,
          moving_date: @moving_date,
        )
      when :cat_2_exemptions_questions
        redirect_to cat_2_questions_green_lanes_check_moving_requirements_path(
          commodity_code: @commodity_code,
          country_of_origin: @country_of_origin,
          moving_date: @moving_date,
        )
      end
    end

    def cat_1_exemptions_questions
      @goods_nomenclature = GreenLanes::GoodsNomenclature.find(
        questions_page_params[:commodity_code],
        { filter: { geographical_area_id: questions_page_params[:country_of_origin] } },
        { authorization: TradeTariffFrontend.green_lanes_api_token },
      )
    end

    def cat_1_exemptions_questions_update
      # This came from result page
      # TODO: params[:exemptions_answers_form, :commodity_code, :country_of_origin, :moving_date]

      exemptions_apply = exemptions_apply?(params[:cat_1_exemptions_apply])

      goods_nomenclature = questions_page_params[:commodity_code]

      if exemptions_apply
        next_page = GreenLanes::DetermineNextPage
                      .new(goods_nomenclature)
                      .next(cat_1_exemptions_apply: exemptions_apply)
        case next_page
        when :result_cat_2
          redirect_to cat_2_questions_green_lanes_check_moving_requirements_path
        when :result_cat_3
          redirect_to result_cat_3_green_lanes_check_moving_requirements_path
        when :cat_2_exemptions_questions
          redirect_to cat_2_questions_green_lanes_check_moving_requirements_path(
            commodity_code: @commodity_code,
            country_of_origin: @country_of_origin,
            moving_date: @moving_date,
          )
        end
      else
        redirect_to result_cat_1_green_lanes_check_moving_requirements_path
      end
    end

    def result_cat_1; end

    def result_cat_2; end

    def result_cat_3; end

    private

    def exemptions_apply?(_exemptions_answers_form)
      # TODO: code this after Sam has implemented the form
      params[:cat_1_exemptions_apply] == 'true'
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
