# frozen_string_literal: true

class ClientLocation
  HEADER = 'CloudFront-Viewer-Country-Name'

  attr_reader :location_header

  def initialize(request_headers)
    @location_header = request_headers[HEADER].presence
  end

  def unknown?
    location_header.blank?
  end

  def united_kingdom?
    location_header == 'United Kingdom'
  end
end
