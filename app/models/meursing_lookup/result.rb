module MeursingLookup
  class Result
    CURRENT_MEURSING_ADDITIONAL_CODE_KEY = :current_meursing_additional_code_id

    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :meursing_additional_code_id

    def persisted?
      false
    end
  end
end
