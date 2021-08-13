require 'api_entity'

class LegalAct
  include ApiEntity

  attr_accessor :published_date,
                :officialjournal_number,
                :officialjournal_page,
                :information_text,
                :regulation_code,
                :regulation_url

  attr_reader :validity_start_date,
              :validity_end_date

  def validity_start_date=(date)
    @validity_start_date = Date.parse(date) if date.present?
  end

  def validity_end_date=(date)
    @validity_end_date = Date.parse(date) if date.present?
  end
end
