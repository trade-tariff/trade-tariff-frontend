module WebchatHelper
  def webchat_link
    link_to('Digital Assistant (opens in new tab)', TradeTariffFrontend.webchat_url, target: '_blank', rel: 'noopener')
  end

  def webchat_visible_in_footer?
    %w[commodities headings subheadings chapters sections].include?(controller_name)
  end
end
