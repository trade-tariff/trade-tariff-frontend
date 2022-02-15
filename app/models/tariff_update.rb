class TariffUpdate
  include ApiEntity

  collection_path '/updates/latest'

  def applied_at
    Date.parse(attributes['applied_at'])
  end

  def self.latest_applied_import_date
    TradeTariffFrontend::ServiceChooser.cache_with_service_choice('tariff_last_updated', expires_in: 23.hours) do
      all.first.try(:applied_at) || Time.zone.today
    end
  end
end
