require 'api_entity'

class SimplifiedProceduralCode
  include ApiEntity

  collection_path '/simplified_procedural_code_measures'

  attr_accessor :validity_start_date, :validity_end_date

  def self.valid_start_dates
    all.map(&:validity_start_date).uniq.compact
  end
end
