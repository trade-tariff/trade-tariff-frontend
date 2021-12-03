require 'api_entity'
require 'digest'

class RulesOfOrigin::Link
  include ApiEntity

  attr_accessor :text, :url
  attr_writer :id

  def id
    @id ||= Digest::MD5.hexdigest("#{url}-#{text}")
  end
end
