require 'active_model'

class Feedback
  include ActiveModel::Model

  attr_accessor :message, :name, :email

  validates :message, presence: true,
                      length: { minimum: 10, maximum: 500 }

  validates :name, length: { maximum: 100 }

  validates :email, length: { maximum: 100 },
                    format: { with: URI::MailTo::EMAIL_REGEXP },
                    allow_blank: true
end
