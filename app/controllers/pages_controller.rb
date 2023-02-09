class PagesController < ApplicationController
  before_action :disable_search_form,
                :disable_last_updated_footnote

  def glossary
    @glossary = Pages::Glossary.find(params[:id])
  end

  def cn2021_cn2022
    @chapters = Chapter.all
  end

  def opensearch
    respond_to do |format|
      format.xml
    end
  end

  def terms; end
  def tools; end
  def privacy; end
  def help; end
  def help_find_commodity; end

  def rules_of_origin_duty_drawback
    @schemes = RulesOfOrigin::Scheme.with_duty_drawback_articles
  end

  def rules_of_origin_proof_requirements
    disable_switch_service_banner

    @commodity_code, @country_code, @scheme_code = params[:id].split('-', 3)
    @country = GeographicalArea.find(@country_code)
    @all_schemes = RulesOfOrigin::Scheme.for_heading_and_country(@commodity_code, @country_code)
    @chosen_scheme = @all_schemes.find { |scheme| scheme.scheme_code == @scheme_code }
    @article = @chosen_scheme.article('origin_processes')
  end
end
