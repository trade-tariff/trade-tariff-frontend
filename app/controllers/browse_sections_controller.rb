class BrowseSectionsController < ApplicationController
  def index
    @sections = Section.all
  end
end
