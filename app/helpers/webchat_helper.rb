module WebchatHelper
  def webchat_link(text='Digital Assistant (opens in new tab)')
    link_to(text, TradeTariffFrontend.webchat_url, target: '_blank', rel: 'noopener')
  end

  def webchat_visible_in_footer?
    %w[commodities headings subheadings chapters sections].include?(controller_name)
  end
end
