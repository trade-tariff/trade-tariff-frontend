class PagesController < ApplicationController
  before_action :disable_search_form,
                :disable_last_updated_footnote

  def index
    @section_css = 'govuk-visually-hidden'
    @meta_description = I18n.t('meta_description')
  end

  def cn2021_cn2022
    @chapters = Chapter.all
  end

  def opensearch
    respond_to do |format|
      format.xml
    end
  end

  def tools
    disable_search_form
  end
end
