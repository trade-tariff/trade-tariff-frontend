class FootnoteSearchController < ApplicationController
  include CodeSearchable

  def self.form_class = FootnoteSearchForm
  def self.model_class = Footnote
  def self.results_ivar = :@footnotes
  def self.search_template = 'search/footnote_search'
  def self.form_param_key = :footnote_search_form
end
