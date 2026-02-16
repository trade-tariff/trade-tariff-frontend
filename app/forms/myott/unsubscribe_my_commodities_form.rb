class Myott::UnsubscribeMyCommoditiesForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :decision, :string

  validates :decision, presence: { message: 'Select yes if you want to unsubscribe from your commodity watch list' },
                       inclusion: { in: %w[true false], message: 'Select yes if you want to unsubscribe from your commodity watch list' }

  def confirmed?
    valid? && decision == 'true'
  end

  def declined?
    valid? && decision == 'false'
  end
end
