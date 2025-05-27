class DutyOptionResult
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :type
  attribute :category
  attribute :footnote
  attribute :measure_sid
  attribute :priority
  attribute :source
  attribute :value
  attribute :values
  attribute :warning_text
  attribute :order_number
  attribute :geographical_area_description
  attribute :scheme_code

  def footnote
    super + footnote_suffix
  end

  def footnote_suffix
    @footnote_suffix.presence || ''.html_safe
  end

  def footnote_suffix=(suffix)
    return if @footnote_suffix

    @footnote_suffix = suffix
  end

  def show_rules_of_origin?
    uk? && scheme_code.present?
  end

  private

  def uk?
    source == 'uk'
  end
end
