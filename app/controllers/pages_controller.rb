class PagesController < ApplicationController
  before_action :disable_search_form,
                :disable_last_updated_footnote

  def cn2021_cn2022
    @chapters = Chapter.all
  end

  def terms; end
  def tools; end
  def privacy; end
  def help; end
  def help_find_commodity; end
end
