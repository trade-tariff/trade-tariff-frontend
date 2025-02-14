class TariffUpdate
  include ApiEntity

  attr_accessor :update_type,
                :state,
                :created_at,
                :updated_at,
                :filename

  attr_writer :applied_at

  set_collection_path '/api/v2/updates/latest'

  def applied_at
    Date.parse(@applied_at)
  end

  def self.latest_applied_import_date
    all.first.try(:applied_at) || Time.zone.today
  end
end
