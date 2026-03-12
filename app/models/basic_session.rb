class BasicSession
  include ActiveModel::Model

  attr_accessor :return_url, :password

  validate :password_recognised

  private

  def password_recognised
    return if TradeTariffFrontend.basic_session_passwords.include?(password)

    errors.add(:password, :inclusion)
  end
end
