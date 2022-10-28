require 'api_entity'

class RulesOfOrigin::Article
  include ApiEntity

  attr_accessor :article, :content

  def text
    content.sub(/{{.*}}/i, '') if content
  end

  def ord_reference
    content.scan(/{{(.*)}}/i).first&.first&.strip if content
  end

  def ord_reference?
    !ord_reference.nil?
  end
end
