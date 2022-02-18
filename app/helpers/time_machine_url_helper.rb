module TimeMachineUrlHelper
  def commodity_on_date_path(commodity, date)
    commodity_path commodity, extract_date_params(date)
  end

  def heading_on_date_path(heading, date)
    heading_path heading, extract_date_params(date)
  end

  def chapter_on_date_path(chapter, date)
    chapter_path chapter, extract_date_params(date)
  end

private

  def extract_date_params(date)
    if date.respond_to?(:day) && date.respond_to?(:month) && date.respond_to?(:year)
      { 'day' => date.day, 'month' => date.month, 'year' => date.year }
    else
      { 'day' => nil, 'month' => nil, 'year' => nil }
    end
  end
end
