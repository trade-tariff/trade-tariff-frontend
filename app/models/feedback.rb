require 'active_model'

class Feedback
  include ActiveModel::Model

  attr_accessor :message, :name, :email

  validates :message, presence: true
  validates :message, length: { minimum: 10, maximum: 500 }

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
end
