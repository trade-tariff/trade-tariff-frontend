require 'api_entity'

class TariffUpdate
  include ApiEntity

  collection_path '/updates/latest'

  attr_accessor :update_type, :state, :created_at, :updated_at, :filename

  def update_type
    case attributes['update_type']
    when /Taric/ then 'TARIC'
    when /Chief/ then 'CHIEF'
    end
  end

  def updated_at
    date_attribute('updated_at')
  end

  def applied_at
    date_attribute('applied_at')
  end

  def to_s
    "Applied #{update_type} at #{updated_at} (#{filename})"
  end

  class << self
    def latest_applied_import_date
      func = Proc.new do
        last = all.first
        last.try(:applied_at) || Date.current
      end

      if Rails.env.test? || Rails.env.development?
        # Do not cache it in Test and Development environments.
        #
        func.call
      else
        # Cache for 1 hour
        TradeTariffFrontend::ServiceChooser.cache_with_service_choice(
          'tariff_last_updated', expires_in: 1.hour
        ) do
          func.call
        end
      end
    end
  end

  private

  def date_attribute(attr_name)
    Date.parse(attributes[attr_name].to_s)
  end
end
