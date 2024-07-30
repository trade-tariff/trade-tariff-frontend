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

  def render_exemptions_or_no_card(category, assessments)
    no_exemptions = assessments.public_send("no_cat#{category}_exemptions")
    exemptions_met = assessments.public_send("cat_#{category}_exemptions_met")

    total_exemptions = assessments.public_send("cat_#{category}_exemptions")

    all_exemptions_met = total_exemptions.count == exemptions_met.count

    if no_exemptions || !all_exemptions_met
      render('category_assessments_card', category:)
    else
      render 'exemptions_card', category:
    end
  end

  def exemptions_met?(category, category_assessment, answers)
    category = category.to_s

    category_assessment_answer = answers.dig(category, category_assessment.category_assessment_id.to_s)

    category_assessment_answer.present? && category_assessment_answer != %w[none]
  end

  private

  def category_assessments_checked(category_assessment_id)
    exemptions = params[:exemptions]
    return if exemptions.nil? || exemptions[:category_assessments_checked].nil?

    exemptions[:category_assessments_checked][category_assessment_id.to_s]
  end
end
