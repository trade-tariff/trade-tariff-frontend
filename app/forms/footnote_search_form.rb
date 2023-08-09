class FootnoteSearchForm
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

  delegate :present?, to: :instance_variables

  def to_params
    {
      code:,
      type:,
      description:,
    }
  end
end
