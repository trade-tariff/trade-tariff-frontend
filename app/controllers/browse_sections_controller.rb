class BrowseSectionsController < ApplicationController
  before_action { disable_search_form }

  def index
    @sections = Section.all
  end
end
