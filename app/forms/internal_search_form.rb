class InternalSearchForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  MAX_QUERY_LENGTH = 100
  MIN_QUERY_LENGTH = 2

  attribute :q, :string
  attribute :answer, :string
  attribute :request_id, :string

  validates :q, presence: true, length: { minimum: MIN_QUERY_LENGTH, maximum: MAX_QUERY_LENGTH }
  validates :answer, presence: true, on: :answer

  def initialize(attributes = {})
    sanitised = sanitise_query(attributes[:q] || attributes['q'])
    super(attributes.merge(q: sanitised))
  end

  private

  def sanitise_query(value)
    return nil if value.blank?

    value.to_s.strip.gsub(/[\[\]]/, '').first(MAX_QUERY_LENGTH)
  end
end
