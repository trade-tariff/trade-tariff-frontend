module TariffChanges
  class TariffChange
    include AuthenticatableApiEntity

    set_collection_path '/uk/user/tariff_changes'

    attr_accessor :classification_description, :goods_nomenclature_item_id, :date_of_effect, :date_of_effect_visible

    def self.download_file(token, opts = {})
      path = "#{collection_path}/download"
      response = api.get(path, opts, headers(token))

      {
        body: response.body,
        filename: response.headers['content-disposition'][/filename="?([^"]*)"?/, 1],
        type: response.headers['content-type'],
      }
    end
  end
end
