module GreenLanes
  class EligibilityForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveRecord::AttributeAssignment

    # all as strings atm but 3 can be converted to boolean with one having not_sure

    attribute :commodity_code, :string
    attribute :moving_goods_gb_to_ni, :string
    attribute :free_circulation_in_uk, :string
    attribute :end_consumers_in_uk, :string
    attribute :ukims, :string
  end
end
