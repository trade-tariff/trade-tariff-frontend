require 'api_entity'

class PreferenceCode
  include ApiEntity

  attr_accessor :code, :description
end
