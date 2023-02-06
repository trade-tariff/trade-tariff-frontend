module RulesOfOrigin
  class ProductSpecificRulesController < ApplicationController
    before_action :disable_switch_service_banner, :disable_search_form

    def index
      @commodity = Commodity.find(params[:commodity])
      @schemes = RulesOfOrigin::Scheme.with_rules_for_commodity(@commodity)
    end
  end
end
