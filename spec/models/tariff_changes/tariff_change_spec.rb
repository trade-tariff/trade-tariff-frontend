RSpec.describe TariffChanges::TariffChange, type: :model do
  it 'sets and gets classification_description' do
    change = described_class.new
    change.classification_description = 'desc'
    expect(change.classification_description).to eq('desc')
  end

  it 'sets and gets goods_nomenclature_item_id' do
    change = described_class.new
    change.goods_nomenclature_item_id = '1234567890'
    expect(change.goods_nomenclature_item_id).to eq('1234567890')
  end

  it 'sets and gets date_of_effect' do
    change = described_class.new
    change.date_of_effect = Time.zone.today
    expect(change.date_of_effect).to eq(Time.zone.today)
  end
end
