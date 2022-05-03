module SearchResult
  class SubheadingSerializer < CommoditySerializer
    include ActiveModel::Serializers::JSON
    def serializable_hash(_opts = {})
      super.merge(type: 'subheading')
    end
  end
end
