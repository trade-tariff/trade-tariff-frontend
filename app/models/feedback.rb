require 'active_model'

class Feedback
  TOKEN_TRACKING_PREFIX = 'feedback-delivery'.freeze
  TOKEN_TRACKING_LIFETIME = 1.hour
  TOKEN_TRACKING_MAX_USAGE = 3

  include ActiveModel::Model

  attr_accessor :message, :telephone, :authenticity_token

  validates :message, presence: true,
                      length: { minimum: 10, maximum: 500 }

  validates :authenticity_token, presence: true,
                                 length: { minimum: 50, maximum: 100 }
  validate :authenticity_token_reuse, if: :authenticity_token

  validate :honeypot_catcher

  def record_delivery!
    Rails.cache.write(tracking_token, tracking_token_count + 1, expires_in: TOKEN_TRACKING_LIFETIME)
  end

  private

  def authenticity_token_reuse
    return if tracking_token_count < TOKEN_TRACKING_MAX_USAGE

    errors.add :message, 'You have sent too many feedbacks, try again later'
  end

  def tracking_token
    [TOKEN_TRACKING_PREFIX, filtered_authenticity_token].join('-')
  end

  def tracking_token_count
    Rails.cache.read(tracking_token) || 0
  end

  def filtered_authenticity_token
    @authenticity_token.to_s.gsub(/[^A-Za-z0-9_-]/, '')
  end

  def honeypot_catcher
    if telephone.present?
      errors.add(:telephone, 'must be kept blank')
    end
  end
end
