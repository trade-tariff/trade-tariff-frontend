class BrowseSectionsController < ApplicationController
  before_action { @no_shared_search = true }

  def index
    @sections = Section.all
  end
end
