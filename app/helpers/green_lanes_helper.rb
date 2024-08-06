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

  def exemption_met?(category, category_assessment, answers)
    return false if answers.blank?

    category = category.to_s

    category_assessment_answer = answers.dig(category, category_assessment.category_assessment_id.to_s)

    category_assessment_answer.present? && category_assessment_answer != %w[none]
  end

  def all_exemptions_met?(category, category_assessments, answers)
    category_assessments.all? { |ca| exemption_met?(category, ca, answers) }
  end

  def render_exemptions(assessments, category)
    if category.to_s == '3'
      render_all_exemptions(assessments) if assessments.cat_1_exemptions_met || assessments.cat_2_exemptions_met
    elsif assessments.cat_1_exemptions_met || assessments.cat_2_exemptions_met || !assessments.no_cat1_exemptions
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
    exemptions = params[:exemptions]
    return if exemptions.nil? || exemptions[:category_assessments_checked].nil?

    exemptions[:category_assessments_checked][category_assessment_id.to_s]
  end
end
