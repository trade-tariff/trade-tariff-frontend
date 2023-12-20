FactoryBot.define do
  factory :search_outcome, class: 'Search::Outcome' do
    trait :fuzzy_match do
      type { 'fuzzy_match' }
      goods_nomenclature_match do
        {
          "chapters": [],
          "commodities": [
            {
              "_index": 'tariff-commodities-uk',
              "_id": '54631',
              "_score": 13.415359,
              "_source": {
                "id": 54_631,
                "goods_nomenclature_item_id": '9603210000',
                "producline_suffix": '80',
                "validity_start_date": '1972-01-01T00:00:00.000Z',
                "validity_end_date": nil,
                "description": 'Toothbrushes, including dental-plate brushes',
                "description_indexed": 'toothbrushes, including dental-plate brushes toothbrushes, shaving brushes, hairbrushes, nail brushes, eyelash brushes and other toilet brushes for use on the person, including such brushes constituting parts of appliances brooms, brushes (including brushes constituting parts of machines, appliances or vehicles), hand-operated mechanical floor sweepers miscellaneous manufactured articles',
                "number_indents": 2,
                "declarable": true,
                "ancestor_descriptions": [
                  'Miscellaneous manufactured articles',
                  'Brooms, brushes (including brushes constituting parts of machines, appliances or vehicles), hand-operated mechanical floor sweepers, not motorised, mops and feather dusters; prepared knots and tufts for broom or brush making; paint pads and rollers; squeegees (other than roller squeegees)',
                  'Toothbrushes, shaving brushes, hairbrushes, nail brushes, eyelash brushes and other toilet brushes for use on the person, including such brushes constituting parts of appliances',
                  'Toothbrushes, including dental-plate brushes',
                ],
                "section": {
                  "numeral": 'XX',
                  "title": 'Miscellaneous manufactured articles',
                  "position": 20,
                },
                "chapter": {
                  "goods_nomenclature_sid": 54_615,
                  "goods_nomenclature_item_id": '9600000000',
                  "producline_suffix": '80',
                  "validity_start_date": '1971-12-31T00:00:00.000Z',
                  "validity_end_date": nil,
                  "description": 'Miscellaneous manufactured articles',
                  "guides": [],
                },
                "heading": {
                  "goods_nomenclature_sid": 54_628,
                  "goods_nomenclature_item_id": '9603000000',
                  "producline_suffix": '80',
                  "validity_start_date": '1972-01-01T00:00:00.000Z',
                  "validity_end_date": nil,
                  "description": 'Brooms, brushes (including brushes constituting parts of machines, appliances or vehicles), hand-operated mechanical floor sweepers, not motorised, mops and feather dusters; prepared knots and tufts for broom or brush making; paint pads and rollers; squeegees (other than roller squeegees)',
                  "number_indents": 0,
                },
              },
            },
          ],
          "headings": [],
          "sections": [],
        }
      end

      reference_match do
        {
          "chapters": [],
          "commodities": [
            {
              "_index": 'tariff-search_references-uk',
              "_id": '9717',
              "_score": 8.104948,
              "_source": {
                "title": 'electric toothbrushes, electric',
                "title_indexed": 'electric toothbrushes, electric',
                "reference_class": 'Commodity',
                "reference": {
                  "id": 49_912,
                  "goods_nomenclature_item_id": '8509800000',
                  "producline_suffix": '80',
                  "validity_start_date": '1972-01-01T00:00:00.000Z',
                  "validity_end_date": nil,
                  "description": 'Other appliances',
                  "description_indexed": 'other appliances electromechanical domestic appliances, with self-contained electric motor electrical machinery and equipment and parts thereof; sound recorders and reproducers, television image and sound recorders and reproducers, and parts and accessories of such articles',
                  "number_indents": 1,
                  "declarable": true,
                  "ancestor_descriptions": [
                    'Electrical machinery and equipment and parts thereof; sound recorders and reproducers, television image and sound recorders and reproducers, and parts and accessories of such articles',
                    'Electromechanical domestic appliances, with self-contained electric motor, other than vacuum cleaners of heading 8508',
                    'Other appliances',
                  ],
                  "section": {
                    "numeral": 'XVI',
                    "title": 'Machinery and mechanical appliances; electrical equipment; parts thereof, sound recorders and reproducers, television image and sound recorders and reproducers, and parts and accessories of such articles',
                    "position": 16,
                  },
                  "chapter": {
                    "goods_nomenclature_sid": 49_496,
                    "goods_nomenclature_item_id": '8500000000',
                    "producline_suffix": '80',
                    "validity_start_date": '1971-12-31T00:00:00.000Z',
                    "validity_end_date": nil,
                    "description": 'Electrical machinery and equipment and parts thereof; sound recorders and reproducers, television image and sound recorders and reproducers, and parts and accessories of such articles',
                    "guides": [],
                  },
                  "heading": {
                    "goods_nomenclature_sid": 49_905,
                    "goods_nomenclature_item_id": '8509000000',
                    "producline_suffix": '80',
                    "validity_start_date": '1972-01-01T00:00:00.000Z',
                    "validity_end_date": nil,
                    "description": 'Electromechanical domestic appliances, with self-contained electric motor, other than vacuum cleaners of heading 8508',
                    "number_indents": 0,
                  },
                  "class": 'Commodity',
                },
              },
            },
          ],
          "headings": [],
          "sections": [],
        }
      end
    end

    initialize_with { new(attributes) }
  end
end
