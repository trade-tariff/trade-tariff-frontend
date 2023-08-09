class FootnoteSearchForm
  OPTIONAL_PARAMS = [:@page].freeze

  attr_accessor :code, :type, :description

  def initialize(params)
    params.each do |key, value|
      public_send("#{key}=", value) if respond_to?("#{key}=") && value.present?
    end
  end

  def footnote_types
    FootnoteType.all.sort_by(&:footnote_type_id).map { |type|
      ["#{type&.footnote_type_id} - #{type&.description}", type&.footnote_type_id]
    }.to_h
  end

  def page
    @page || 1
  end

  def present?
    (instance_variables - OPTIONAL_PARAMS).present?
  end

  def to_params
    {
      code:,
      type:,
      description:,
      page:,
    }
  end
end
