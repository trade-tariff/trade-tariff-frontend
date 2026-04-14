class AdditionalCodeSearchController < ApplicationController
  include CodeSearchable

  def self.form_class = AdditionalCodeSearchForm
  def self.model_class = AdditionalCode
  def self.results_ivar = :@additional_codes
  def self.search_template = 'search/additional_code_search'
  def self.form_param_key = :additional_code_search_form
end
