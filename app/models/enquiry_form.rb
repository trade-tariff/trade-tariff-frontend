class EnquiryForm
  include UkOnlyApiEntity

  set_singular_path 'enquiry_form/submissions'

  attr_accessor :name, :company_name, :job_title, :email, :enquiry_category, :enquiry_description

  def self.create!(attributes)
    json_api_params = {
      data: {
        attributes: attributes,
      },
    }

    body = json_api_params.to_json
    headers = { 'Content-Type' => 'application/json' }

    super(body, headers)
  rescue Faraday::ClientError => e
    Rails.logger.error("EnquiryForm.create! failed: #{e.class} - #{e.message}")
    nil
  end
end
