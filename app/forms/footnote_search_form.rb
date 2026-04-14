class FootnoteSearchForm < CodeSearchForm
  class << self
    def code_length = 5
    def type_length = 2
    def valid_types = footnote_types

    def footnote_types
      @footnote_types ||= FootnoteType.all.map(&:footnote_type_id).sort
    end
  end
end
