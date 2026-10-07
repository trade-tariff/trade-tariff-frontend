class ParcelGiftChoiceForm
  include ActiveModel::Model

  attr_accessor :choice
  attr_reader :journey, :service_name

  validate :known_choice

  def initialize(journey:, service_name:, choice: nil)
    @journey = journey
    @service_name = service_name
    super(choice:)
  end

  def available_steps
    journey.steps_for(service_name)
  end

  def selected_step
    journey.find_step(choice, service_name:)
  end

  private

  def known_choice
    errors.add(:choice, journey.chooser.error) unless choice.is_a?(String) && selected_step
  end
end
