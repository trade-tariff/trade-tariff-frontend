module GreenLanesHelper
  def exemption_checkbox_checked?(category_assessment_id, exemption_code)
    cas_checked = category_assessments_checked(category_assessment_id)

    return if cas_checked.nil?

    cas_checked.include?(exemption_code)
  end

  def exemption_checkbox_none?(category_assessment_id)
    cas_checked = category_assessments_checked(category_assessment_id)

    return if cas_checked.nil?

    cas_checked.include?('none')
  end

  def all_exemption_questions_replied?(questions_count)
    checked = params[:exemptions][:category_assessments_checked]
    questions_replied_count = checked ? checked.keys.count : 0

    questions_count == questions_replied_count
  end

  private

  def category_assessments_checked(category_assessment_id)
    exemptions = params[:exemptions]
    return if exemptions.nil? || exemptions[:category_assessments_checked].nil?

    exemptions[:category_assessments_checked][category_assessment_id.to_s]
  end
end
