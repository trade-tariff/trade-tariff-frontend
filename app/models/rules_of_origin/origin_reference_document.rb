require 'api_entity'
require 'digest'

class RulesOfOrigin::OriginReferenceDocument
  include ApiEntity

  attr_accessor :ord_title, :ord_version, :ord_date, :ord_original
end
