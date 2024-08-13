module GreenLanesHelper
  def exemption_checkbox_checked?(category_assessment_id, exemption_code)
    category_assessments_checked(category_assessment_id)&.include?(exemption_code)
  end

  def exemption_checkbox_none?(category_assessment_id)
    exemption_checkbox_checked?(category_assessment_id, 'none')
  end

  def render_exemptions_or_no_card(category, assessments)
    no_exemptions = assessments.public_send("no_cat#{category}_exemptions")
    exemptions_met = assessments.public_send("cat_#{category}_exemptions_met")
    total_exemptions = assessments.public_send("cat_#{category}_exemptions")

    all_exemptions_met = total_exemptions.count == exemptions_met.count

    template = no_exemptions || !all_exemptions_met ? 'category_assessments_card' : 'exemptions_card'
    render(template, category:)
  end

  def exemption_met?(exemption_code, category, category_assessment, answers)
    return false if answers.blank?

    category_assessment_answer = dig_category_answer(answers, category, category_assessment.category_assessment_id)
    category_assessment_answer.present? && category_assessment_answer != %w[none] && category_assessment_answer.include?(exemption_code)
  end

  def all_exemptions_met?(category, category_assessments, answers)
    return false if answers.blank?

    category_assessments.all? do |ca|
      category_assessment_answer = dig_category_answer(answers, category, ca.category_assessment_id)
      category_assessment_answer.present? && category_assessment_answer != %w[none]
    end
  end

  def render_exemptions(assessments, category)
    if category.to_s == '3'
      render_all_exemptions(assessments) if any_exemptions_met?(assessments)
    elsif any_exemptions_met?(assessments) || !assessments.no_cat1_exemptions
      result = render_exemptions_or_no_card(1, assessments)
      result += render_exemptions_or_no_card(2, assessments) unless assessments.cat_1_exemptions_not_met
      result
    end
  end

  def yes_no_options
    [OpenStruct.new(id: 'yes', name: 'Yes'), OpenStruct.new(id: 'no', name: 'No')]
  end

  def yes_no_not_sure_options
    [OpenStruct.new(id: 'yes', name: 'Yes'), OpenStruct.new(id: 'no', name: 'No'), OpenStruct.new(id: 'not_sure', name: 'Not sure')]
  end

  private

  def render_all_exemptions(assessments)
    safe_join([render_exemptions_or_no_card(1, assessments), render_exemptions_or_no_card(2, assessments)])
  end

  def category_assessments_checked(category_assessment_id)
    params.dig(:exemptions, :category_assessments_checked, category_assessment_id.to_s)
  end

  def dig_category_answer(answers, category, category_assessment_id)
    answers.dig(category.to_s, category_assessment_id.to_s)
  end

  def any_exemptions_met?(assessments)
    assessments.cat_1_exemptions_met || assessments.cat_2_exemptions_met
  end
end
