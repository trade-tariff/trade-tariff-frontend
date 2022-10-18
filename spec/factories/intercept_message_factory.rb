FactoryBot.define do
  factory :intercept_message, class: 'Beta::Search::InterceptMessage' do
    term { 'access equipment' }
    message { 'Electrical goods would be classified under chapter 85, computer hardware under heading 8517, clothing accessories under heading 6117, heading 6213, heading 6214, heading 6215, heading 6216, heading 6217 and heading 6307, otherwise please specify.' }
    formatted_message { 'Electrical goods would be classified under [chapter 85](/chapters/85), computer hardware under [heading 8517](/headings/8517), clothing accessories under [heading 6117](/headings/6117), [heading 6213](/headings/6213), [heading 6214](/headings/6214), [heading 6215](/headings/6215), [heading 6216](/headings/6216), [heading 6217](/headings/6217) and [heading 6307](/headings/6307), otherwise please specify.' }
  end
end
