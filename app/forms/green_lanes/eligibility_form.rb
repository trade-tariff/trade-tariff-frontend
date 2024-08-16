module GreenLanes
  class EligibilityForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveRecord::AttributeAssignment

    attribute :commodity_code, :string
    attribute :moving_goods_gb_to_ni, :string
    attribute :free_circulation_in_uk, :string
    attribute :end_consumers_in_uk, :string
    attribute :ukims, :string

    validates :moving_goods_gb_to_ni, presence: true
    validates :free_circulation_in_uk, presence: true
    validates :end_consumers_in_uk, presence: true
    validates :ukims, presence: true
  end
end
