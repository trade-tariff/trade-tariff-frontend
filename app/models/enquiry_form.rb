class EnquiryForm
  include ApiEntity

  set_singular_path 'enquiry_form/submissions'

  attr_accessor :name, :company_name, :job_title, :email, :enquiry_category, :enquiry_description

  def self.create!(attributes)
    json_api_params = {
      data: {
        attributes: attributes,
      },
    }

    super(json_api_params, { 'Content-Type' => 'application/json' })
  end
end
