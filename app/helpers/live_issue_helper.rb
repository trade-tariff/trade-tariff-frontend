module LiveIssueHelper
  def markdown_field(attr)
    raw Kramdown::Document.new(attr).to_html
  end
end
