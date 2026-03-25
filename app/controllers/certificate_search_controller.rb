class CertificateSearchController < ApplicationController
  include CodeSearchable

  def self.form_class = CertificateSearchForm
  def self.model_class = Certificate
  def self.results_ivar = :@certificates
  def self.search_template = 'search/certificate_search'
  def self.form_param_key = :certificate_search_form
end
