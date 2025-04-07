class BasicSession
  include ActiveModel::Model

  attr_accessor :return_url, :password

  validates :password, inclusion: { in: [TradeTariffFrontend.basic_session_password] }
end
