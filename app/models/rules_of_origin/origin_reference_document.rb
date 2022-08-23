class RulesOfOrigin::OriginReferenceDocument
  include ApiEntity

  attr_accessor :ord_title, :ord_version, :ord_date, :ord_original

  def document_path
    File.join("/roo_origin_reference_documents/#{ord_original}")
  end
end
