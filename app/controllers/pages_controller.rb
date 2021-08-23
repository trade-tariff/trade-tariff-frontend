class PagesController < ApplicationController
  before_action do
    @tariff_last_updated = nil
  end

  def index
    @section_css = 'govuk-visually-hidden'
    @meta_description = I18n.t('meta_description')
  end

  def opensearch
    respond_to do |format|
      format.xml
    end
  end

  def tools
    @no_shared_search = true
  end
end
