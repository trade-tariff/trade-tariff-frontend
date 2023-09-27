class ChangePresenter
  attr_reader :change

  delegate :record, to: :change, prefix: true

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

  private

  # rubocop:disable Style/MissingRespondToMissing
  def method_missing(*args, &block)
    @change.send(*args, &block)
  end
  # rubocop:enable Style/MissingRespondToMissing
end
