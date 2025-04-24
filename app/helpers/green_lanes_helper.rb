module GreenLanesHelper
  def exemption_checkbox_checked?(resource_id, exemption_code)
    params.dig(:exemptions, resource_id.to_s)
          &.include?(exemption_code)
  end

  def exemption_checkbox_none?(resource_id)
    exemption_checkbox_checked?(resource_id, 'none')
  end

  def render_exemptions_or_no_card(category, assessments, result)
    no_exemptions = assessments.send("no_cat#{category}_exemptions")
    assessments_met = assessments.send("cat_#{category}_assessments_met")
    total_assessments = assessments.send("cat_#{category}_assessments").pluck(:resource_id).map(&:to_s)

    all_assessments_met = total_assessments.count == assessments_met.count

    if result == '3'
      render('exemptions_card', category:)
    else
      template = no_exemptions || !all_assessments_met ? 'category_assessments_card' : 'exemptions_card'
      render(template, category:)
    end
  end

  def exemption_met?(exemption_code, category, category_assessment, answers)
    return false if answers.blank?

    category_assessment_answer = dig_category_answer(answers, category, category_assessment.resource_id)
    category_assessment_answer.present? && category_assessment_answer != %w[none] && category_assessment_answer.include?(exemption_code)
  end

  def all_exemptions_met?(category, category_assessments, answers)
    return false if answers.blank?

    category_assessments.all? do |ca|
      category_assessment_answer = dig_category_answer(answers, category, ca.resource_id)
      category_assessment_answer.present? && category_assessment_answer != %w[none]
    end
  end

  def render_exemptions(assessments, result)
    view = []

    case result
    when '1'
      view << render_exemptions_or_no_card(1, assessments, result) if assessments.send('cat_1_exemptions').present? || @cas_without_exemptions.present?
    when '2'
      view << render_exemptions_or_no_card(1, assessments, result) if assessments.send('cat_1_exemptions').present?
      view << render_exemptions_or_no_card(2, assessments, result) if assessments.send('cat_2_exemptions').present? || @cas_without_exemptions.present?
    when '3'
      view << render_exemptions_or_no_card(1, assessments, result) if assessments.send('cat_1_exemptions').present?
      view << render_exemptions_or_no_card(2, assessments, result) if assessments.send('cat_2_exemptions').present?
    end

    safe_join(view)
  end

  def yes_no_options
    [OpenStruct.new(id: 'yes', name: 'Yes'), OpenStruct.new(id: 'no', name: 'No')]
  end

  def yes_no_not_sure_options
    [OpenStruct.new(id: 'yes', name: 'Yes'), OpenStruct.new(id: 'no', name: 'No'), OpenStruct.new(id: 'not_sure', name: 'Not sure')]
  end

  def prettify_category(category)
    case category.to_i
    when 1, 2
      category.to_s
    when 3
      'standard'
    end
  end

  def hide_pseudo_code(code)
    code.start_with?('WFE') ? '' : code
  end

  def format_pseudo_code_for_exemption(exemption)
    sanitize(exemption.code.start_with?('WFE') ? exemption.formatted_description.to_s : "#{exemption.code} #{exemption.formatted_description}")
  end

  def unique_exemptions(assessments)
    exemptions = []
    displayed_exemptions = Set.new

    assessments.each do |category_assessment|
      category_assessment.exemptions.each do |exemption|
        unless displayed_exemptions.include?(exemption.code)
          exemptions << [exemption, category_assessment]
          displayed_exemptions.add(exemption.code)
        end
      end
    end

    exemptions
  end

  def exemption_status(exemption, category, category_assessment)
    if exemption_met?(exemption.code, category, category_assessment, @answers)
      'Exemption met'
    else
      'Exemption not met'
    end
  end

  def long_date(string_date)
    date = Date.parse(string_date)
    date.to_formatted_s(:long)
  end

  private

  def dig_category_answer(answers, category, resource_id)
    answers.dig(category.to_s, resource_id.to_s)
  end
end
