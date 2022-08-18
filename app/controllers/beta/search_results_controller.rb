module Beta
  class SearchResultsController < ApplicationController
    POSSIBLE_FILTERS = %w[
      alcohol_volume
      animal_product_state
      animal_type
      art_form
      battery_charge
      battery_grade
      battery_type
      beverage_type
      bone_state
      bovine_age_gender
      bread_type
      brix_value
      cable_type
      car_capacity
      car_type
      cereal_state
      cheese_type
      clothing_fabrication
      clothing_gender
      cocoa_state
      coffee_state
      computer_type
      dairy_form
      egg_purpose
      egg_shell_state
      electrical_output
      electricity_type
      entity
      fat_content
      fish_classification
      fish_preparation
      flour_source
      fruit_spirit
      fruit_vegetable_state
      fruit_vegetable_type
      garment_material
      garment_type
      glass_form
      glass_purpose
      height
      herb_spice_state
      ingredient
      jam_sugar_content
      jewellery_type
      length
      margarine_state
      material
      metal_type
      metal_usage
      monitor_connectivity
      monitor_type
      mounting
      new_used
      nut_state
      oil_fat_source
      pasta_state
      plant_state
      precious_stone
      product_age
      pump_type
      purpose
      sugar_state
      template
      tobacco_type
      vacuum_type
      weight
      wine_origin
      wine_type
      yeast_state
      chapter_id
      heading_id
      producline_suffix
      goods_nomenclature_class
    ].freeze

    def show
      @search_result = Beta::Search::PerformSearchService.new(query, filters).call

      redirect_to missing_search_query_fallback_url if is_redirect?
    end

    private

    def query
      @query ||= search_params[:q].presence || ''
    end

    def filters
      @filters ||= params[:filter]&.permit(*POSSIBLE_FILTERS) || {}
    end

    def search_params
      params.permit(:q, :filters)
    end

    def is_redirect?
      @search_result.meta['redirect'].eql?(true)
    end

    def missing_search_query_fallback_url
      @search_result.meta['redirect_to']
    end
  end
end
