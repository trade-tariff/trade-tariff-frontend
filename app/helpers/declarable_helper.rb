module DeclarableHelper
  def supplementary_unit_for(uk_declarable, xi_declarable, country = nil)
    supplementary_unit = DeclarableUnitService.new(uk_declarable, xi_declarable, country).call

    sanitize supplementary_unit
  end
end
