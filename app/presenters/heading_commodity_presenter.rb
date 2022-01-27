class HeadingCommodityPresenter
  def initialize(commodities)
    @commodities = commodities
  end

  def root_commodities
    @commodities.select(&:root)
  end

  def leaf_commodities_count
    @commodities.select(&:leaf?).length
  end
end
