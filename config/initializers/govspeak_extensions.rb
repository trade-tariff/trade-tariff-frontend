Govspeak::PostProcessor.extension 'wrap tables in divs' do |document|
  document.css('table')
          .wrap('<div class="scroll-x">')
end
