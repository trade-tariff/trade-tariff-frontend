class TariffUpdate
  include ApiEntity

  attr_accessor :update_type,
                :state,
                :created_at,
                :updated_at,
                :filename

  attr_writer :applied_at

  collection_path '/updates/latest'

  def applied_at
    Date.parse(@applied_at)
  end

  def self.latest_applied_import_date
    TradeTariffFrontend::ServiceChooser.cache_with_service_choice('tariff_last_updated', expires_in: 23.hours) do
      all.first.try(:applied_at) || Time.zone.today
    end
  end
end
