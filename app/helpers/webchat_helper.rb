module WebchatHelper
  def webchat_link
    link_to('Digital Assistant (opens in new tab)', "#{TradeTariffFrontend.webchat_url}", target: '_blank')
  end
end
