require 'spec_helper'

RSpec.describe ChemicalSubstance do
  it { is_expected.to respond_to :cus }
  it { is_expected.to respond_to :cas_rn }
  it { is_expected.to respond_to :goods_nomenclature_sid }
  it { is_expected.to respond_to :goods_nomenclature_item_id }
  it { is_expected.to respond_to :producline_suffix }
  it { is_expected.to respond_to :name }
end
