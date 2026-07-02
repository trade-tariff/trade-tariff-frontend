class ChangePresenter
  attr_reader :change

  delegate :record, to: :change, prefix: true
  delegate :id, :operation, :operation_date, to: :change

  def initialize(change)
    @change = change
  end

  def self.model_name
    Change.model_name
  end

  def title
    @change.model_name
  end

  def content
    @change.record
  end

  def operation_name
    options = {
      'C' => 'created',
      'U' => 'updated',
      'D' => 'removed',
    }
    options[operation]
  end

  def anchor_link; end

end
