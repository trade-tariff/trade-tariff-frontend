class EnquiryForm
  include ApiEntity

  attr_accessor :name, :company_name, :job_title, :email, :enquiry_category, :enquiry_description

  def self.create!(attributes)
    json_api_params = {
      data: {
        attributes: attributes,
      },
    }

    request = prepare_json_request(json_api_params, { 'Content-Type' => 'application/json' })
    response = api.post(internal_submission_path, request[:body], request[:headers])

    new parse_jsonapi(response)
  end

  def self.internal_submission_path
    TradeTariffFrontend::ServiceChooser.internal_api_path('enquiry_form/submissions')
  end
end
